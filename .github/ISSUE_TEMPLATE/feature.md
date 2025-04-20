name: "Feature Request"
description: "Suggest a new feature or improvement for this project."
body:
  - type: markdown
    attributes:
      value: |
        ### Feature Request
        Please provide details about the feature you’d like to see added.

  - type: textarea
    id: feature-description
    attributes:
      label: "Feature Description"
      description: "Describe the feature you are requesting."
      placeholder: "Example: Support for a new OS"
    validations:
      required: true

  - type: textarea
    id: use-case
    attributes:
      label: "Use Case"
      description: "Explain why this feature is useful and how it would help users."
      placeholder: "Example: This feature will simplify automation for new Ubuntu releases..."
    validations:
      required: true

  - type: checkboxes
    id: confirmations
    attributes:
      label: "Confirmation"
      description: "Please check the boxes below before submitting."
      options:
        - label: "I have checked for existing feature requests to avoid duplicates."
          required: true
        - label: "This feature is relevant to this project and not a general support request."
          required: true
