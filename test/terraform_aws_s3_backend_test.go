package test

import (
	"context"
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	awsgrunt "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func GetS3BucketEncryption(t *testing.T, c context.Context, client *s3.Client, bucketName string) bool {
	params := &s3.GetBucketEncryptionInput{Bucket: aws.String(bucketName)}
	result, err := client.GetBucketEncryption(c, params)

	if err != nil {
		t.Errorf(err.Error())
	}
	if result == nil {
		return false
	}
	return true
}

func TestTerrafromS3Backend(t *testing.T) {
	awsRegion := awsgrunt.GetRandomStableRegion(t, nil, nil)
	expectedStateBucketNamePrefix := "terratest-aws-s3-backend"
	expectedLogsBucketNamePrefix := "terratest-aws-s3-backend-logs"
	expectedEnvironmentTag := "Automated Testing"
	expectedToolTag := "Terraform"
	expectedDynamoDbTableName := fmt.Sprintf("terratest-state-lock-%s", strings.ToLower(random.UniqueId()))
	expectedTags := map[string]string{
		"Environment": expectedEnvironmentTag,
		"Tool":        expectedToolTag,
	}

	// S3 client config
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		t.Errorf(err.Error())
	}
	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.Region = awsRegion
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures",

		// Variables to pass to the Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket_name_prefix":        expectedStateBucketNamePrefix,
			"dynamodb_table_name":       expectedDynamoDbTableName,
			"bucket_versioning_enabled": "true",
			"bucket_objects_deletion":   "false",
			"tags": map[string]string{
				"Environment": expectedEnvironmentTag,
				"Tool":        expectedToolTag,
			},
		},
		EnvVars: map[string]string{
			"AWS_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Outputs
	stateBucketName := terraform.Output(t, terraformOptions, "state_bucket_name")
	logsBucketName := terraform.Output(t, terraformOptions, "logs_bucket_name")

	// Verify state bucket name
	stateBucketPrefixed := strings.HasPrefix(stateBucketName, expectedStateBucketNamePrefix)
	assert.Equal(t, true, stateBucketPrefixed)

	// Verify logs bucket name
	logsBucketPrefixed := strings.HasPrefix(logsBucketName, expectedLogsBucketNamePrefix)
	assert.Equal(t, true, logsBucketPrefixed)

	// Verify that state bucket has versioning enabled
	actualStatus := awsgrunt.GetS3BucketVersioning(t, awsRegion, stateBucketName)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify that state bucket has server access logging TargetBucket set to what's expected
	loggingTargetBucket := awsgrunt.GetS3BucketLoggingTarget(t, awsRegion, stateBucketName)
	loggingObjectTargetPrefix := awsgrunt.GetS3BucketLoggingTargetPrefix(t, awsRegion, stateBucketName)
	expectedLogsTargetPrefix := "log/"

	strings.HasPrefix(loggingTargetBucket, expectedLogsBucketNamePrefix)
	assert.Equal(t, expectedLogsTargetPrefix, loggingObjectTargetPrefix)

	// Verify state bucket tags
	stateBucketTags := awsgrunt.GetS3BucketTags(t, awsRegion, stateBucketName)
	assert.Equal(t, expectedTags, stateBucketTags)

	// Verify that state bucket has encryption enabled
	bucketEncrypted := GetS3BucketEncryption(t, context.TODO(), client, stateBucketName)
	assert.Equal(t, true, bucketEncrypted)
}
