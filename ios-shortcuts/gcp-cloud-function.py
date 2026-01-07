# Google Cloud Function for VM Control
#
# This Cloud Function provides a simple API for iOS Shortcuts
# to control the Portable Claude Code VM without complex OAuth.
#
# It uses a simple API key for authentication instead of OAuth tokens.
#
# Deploy:
#   gcloud functions deploy vm-control \
#     --runtime python312 \
#     --trigger-http \
#     --allow-unauthenticated \
#     --entry-point vm_control
#
# Then set the API_KEY environment variable

import os
import functions_framework
from google.cloud import compute_v1
import json

# Configuration
PROJECT_ID = os.environ.get("PROJECT_ID", "portable-cc-dev")
ZONE = os.environ.get("ZONE", "us-central1-a")
INSTANCE_NAME = os.environ.get("INSTANCE_NAME", "portable-cc-dev")
API_KEY = os.environ.get("API_KEY", "")

# Initialize Compute client
instances_client = compute_v1.InstancesClient()


def verify_auth(request):
    """Verify the API key from request headers."""
    auth_header = request.headers.get("Authorization", "")
    auth_header = request.headers.get("X-API-Key", auth_header)

    if not auth_header:
        return False

    # Support both "Bearer KEY" and just "KEY" formats
    token = auth_header.replace("Bearer ", "").strip()

    # Constant-time comparison to prevent timing attacks
    return token == API_KEY


@functions_framework.http
def vm_control(request):
    """
    HTTP Cloud Function for VM control.

    Methods:
    - GET: Get VM status
    - POST: Start VM
    - DELETE: Stop VM

    Headers:
    - X-API-Key or Authorization: Bearer <API_KEY>
    """

    # Verify authentication
    if not verify_auth(request):
        return {
            "error": "Unauthorized",
            "message": "Invalid or missing API key"
        }, 401

    # Get request method
    method = request.method.upper()

    try:
        if method == "GET":
            return get_status()
        elif method == "POST":
            return start_vm()
        elif method == "DELETE":
            return stop_vm()
        else:
            return {
                "error": "Method not allowed",
                "message": f"Method {method} not supported. Use GET, POST, or DELETE."
            }, 405

    except Exception as e:
        return {
            "error": "Internal error",
            "message": str(e)
        }, 500


def get_status():
    """Get current VM status."""
    instance = instances_client.get(
        project=PROJECT_ID,
        zone=ZONE,
        instance=INSTANCE_NAME
    )

    return {
        "status": instance.status,
        "name": instance.name,
        "zone": ZONE,
        "machine_type": instance.machine_type.split("/")[-1],
        "last_start": instance.last_start_timestamp if hasattr(instance, "last_start_timestamp") else None
    }


def start_vm():
    """Start the VM."""
    operation = instances_client.start(
        project=PROJECT_ID,
        zone=ZONE,
        instance=INSTANCE_NAME
    )

    return {
        "status": "starting",
        "message": f"VM {INSTANCE_NAME} is starting",
        "operation": operation.name,
        "zone": ZONE
    }


def stop_vm():
    """Stop the VM."""
    operation = instances_client.stop(
        project=PROJECT_ID,
        zone=ZONE,
        instance=INSTANCE_NAME
    )

    return {
        "status": "stopping",
        "message": f"VM {INSTANCE_NAME} is stopping",
        "operation": operation.name,
        "zone": ZONE
    }


# For local testing
if __name__ == "__main__":
    class MockRequest:
        def __init__(self, method, headers=None):
            self.method = method
            self.headers = headers or {}

    # Test with your API key
    os.environ["API_KEY"] = "your-test-api-key"

    test_req = MockRequest("GET", {"X-API-Key": "your-test-api-key"})
    print(vm_control(test_req))
