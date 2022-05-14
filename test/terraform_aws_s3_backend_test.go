package test

import (
    "fmt"
	"strings"
    "testing"

    "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerrafromS3Backend(t *testing.T){
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	expectedStateBucketNamePrefix := "terratest-aws-s3-backend"
	expectedLogsBucketNamePrefix := "terratest-aws-s3-backend-logs"
	expectedEnvironmentTag := "Automated Testing"
	expectedToolTag := "Terraform"
	expectedDynamoDbTableName := fmt.Sprintf("terratest-state-lock-%s", strings.ToLower(random.UniqueId()))
	expectedTags := map[string]string{
		"Environment": expectedEnvironmentTag,
		"Tool": expectedToolTag,
	}

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "./fixtures",
        
        // Variables to pass to the Terraform code using -var options
        Vars: map[string]interface{}{
            "bucket_name_prefix": expectedStateBucketNamePrefix,
			"dynamodb_table_name": expectedDynamoDbTableName,
			"bucket_versioning_enabled": "true",
			"bucket_objects_deletion": "false",
			"tags": map[string]string{
				"Environment": expectedEnvironmentTag,
				"Tool": expectedToolTag,
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
	strings.HasPrefix(stateBucketName, expectedStateBucketNamePrefix)

	// Verify logs bucket name
	strings.HasPrefix(logsBucketName, expectedLogsBucketNamePrefix)

	// Verify that state bucket has versioning enabled
	actualStatus := aws.GetS3BucketVersioning(t, awsRegion, stateBucketName)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify that state bucket has server access logging TargetBucket set to what's expected
	loggingTargetBucket := aws.GetS3BucketLoggingTarget(t, awsRegion, stateBucketName)
	loggingObjectTargetPrefix := aws.GetS3BucketLoggingTargetPrefix(t, awsRegion, stateBucketName)
	expectedLogsTargetPrefix := "log/"

	strings.HasPrefix(loggingTargetBucket, expectedLogsBucketNamePrefix)
	assert.Equal(t, expectedLogsTargetPrefix, loggingObjectTargetPrefix)

	// Verify state bucket tags
	stateBucketTags := aws.GetS3BucketTags(t, awsRegion, stateBucketName)
	assert.Equal(t, expectedTags, stateBucketTags)
}