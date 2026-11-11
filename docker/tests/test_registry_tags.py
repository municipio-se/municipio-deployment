import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "list-ghcr-tags.sh"


class GhcrTagLookupTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.bin_directory = Path(self.temporary_directory.name) / "bin"
        self.bin_directory.mkdir()
        curl = self.bin_directory / "curl"
        curl.write_text(
            """#!/usr/bin/env python3
import os
import sys
from pathlib import Path

args = sys.argv[1:]
count_file = Path(os.environ["MOCK_COUNT_FILE"])
index = int(count_file.read_text()) if count_file.exists() else 0
statuses = os.environ.get("MOCK_STATUSES", os.environ["MOCK_STATUS"]).split("|")
bodies = os.environ.get("MOCK_BODIES", os.environ["MOCK_BODY"]).split("|")
Path(args[args.index("-D") + 1]).write_text(os.environ.get("MOCK_HEADERS", ""))
Path(args[args.index("-o") + 1]).write_text(bodies[min(index, len(bodies) - 1)])
count_file.write_text(str(index + 1))
sys.stdout.write(statuses[min(index, len(statuses) - 1)])
"""
        )
        curl.chmod(0o755)

    def lookup(self, status, body):
        environment = os.environ.copy()
        environment.update(
            {
                "PATH": f"{self.bin_directory}{os.pathsep}{environment['PATH']}",
                "REGISTRY_BEARER_TOKEN": "test-token",
                "MOCK_STATUS": str(status),
                "MOCK_BODY": body,
                "MOCK_COUNT_FILE": str(self.bin_directory / "curl-count"),
            }
        )
        return subprocess.run(
            ["bash", str(SCRIPT), "owner/image"],
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_unknown_package_on_later_page_is_not_treated_as_empty(self):
        body = json.dumps({"name": "owner/image", "tags": ["v1.0.0"]})
        missing = json.dumps({"errors": [{"code": "NAME_UNKNOWN"}]})
        environment = os.environ.copy()
        environment.update(
            {
                "PATH": f"{self.bin_directory}{os.pathsep}{environment['PATH']}",
                "REGISTRY_BEARER_TOKEN": "test-token",
                "MOCK_STATUS": "200",
                "MOCK_BODY": body,
                "MOCK_STATUSES": "200|404",
                "MOCK_BODIES": f"{body}|{missing}",
                "MOCK_HEADERS": 'Link: </v2/owner/image/tags/list?n=1000&last=v1>; rel="next"\r\n',
                "MOCK_COUNT_FILE": str(self.bin_directory / "curl-count"),
            }
        )
        response = subprocess.run(
            ["bash", str(SCRIPT), "owner/image"],
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

        self.assertNotEqual(response.returncode, 0)
        self.assertIn("unexpected HTTP 404", response.stderr)

    def test_unknown_package_returns_empty_tag_list(self):
        response = self.lookup(
            404,
            json.dumps({"errors": [{"code": "NAME_UNKNOWN", "message": "repository not found"}]}),
        )

        self.assertEqual(response.returncode, 0, response.stderr)
        self.assertEqual(response.stdout, "")

    def test_valid_empty_tag_list_returns_empty(self):
        response = self.lookup(200, json.dumps({"name": "owner/image", "tags": []}))

        self.assertEqual(response.returncode, 0, response.stderr)
        self.assertEqual(response.stdout, "")

    def test_registry_auth_and_other_errors_fail(self):
        cases = [
            (401, {"errors": [{"code": "UNAUTHORIZED"}]}),
            (403, {"errors": [{"code": "DENIED"}]}),
            (404, {"errors": [{"code": "DENIED"}]}),
            (500, {"errors": [{"code": "INTERNAL"}]}),
        ]
        for status, body in cases:
            with self.subTest(status=status, body=body):
                response = self.lookup(status, json.dumps(body))
                self.assertNotEqual(response.returncode, 0)
                self.assertIn(f"HTTP {status}", response.stderr)

    def test_malformed_success_response_fails(self):
        response = self.lookup(200, '{"name":"owner/image","tags":[42]}')

        self.assertNotEqual(response.returncode, 0)
        self.assertIn("malformed", response.stderr)


if __name__ == "__main__":
    unittest.main()
