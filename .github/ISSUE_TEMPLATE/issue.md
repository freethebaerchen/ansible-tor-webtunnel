name: "Issue Report"
description: "Report an issue related to this project, including errors, OS details, and additional context."
body:
  - type: markdown
    attributes:
      value: |
        ### 🛠️ Issue Report
        Please fill in the details below to help diagnose the issue.
  
  - type: textarea
    id: error-message
    attributes:
      label: "Error Message"
      description: "Paste the full error message here (including traceback if applicable)."
      placeholder: "Example: ERROR! The task includes an option with an undefined variable..."
    validations:
      required: true
  
  - type: input
    id: os-version
    attributes:
      label: "Operating System & Version"
      description: "Specify the OS and version the target machine is running."
      placeholder: "Example: Ubuntu 24.04, FreeBSD 13.4, CentOS Stream 10"
    validations:
      required: true

  - type: textarea
    id: additional-info
    attributes:
      label: "Additional Information"
      description: "Any extra details, configurations, or steps to reproduce the issue."
      placeholder: "Example: host_vars file (anonymize the values), inventory settings, Ansible version (run `ansible --version`)"
    validations:
      required: false

  - type: checkboxes
    id: confirmations
    attributes:
      label: "Confirmation"
      description: "Please check the boxes below before submitting."
      options:
        - label: "I have searched for existing issues and discussions before opening this."
          required: true
        - label: "I have provided the full error message and OS version."
          required: true
