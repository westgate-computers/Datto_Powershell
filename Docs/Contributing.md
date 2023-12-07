# Datto Powershell Contributing Guide

## Welcome

Welcome to the WAND Contributing Guide, and thank you for your interest.

If you would like to contribute to a specific part of the project, check out the following list of contributions that we accept and their corresponding sections that are within this guide:

* Development
    * Any unassigned issue is free to grab
    * Create a new Feature Request
* Documentation
    * End-User Docs
    * Technical Docs

## Datto Powershell overview

The purpose of the Datto Powershell project is to automate the process of applying vulnerability remediations and any other function needed by the clients of Westgate Computers so that the burden of management can be eased for our Techs.

## Ground rules

Before contributing, read our [Code of Conduct](./Code_Of_Conduct.md) to learn more about our community guidelines and expectations.

## Share ideas

To share your new ideas for the project, perform the following actions:

1. Create a new issue
2. Use the Feature Request template
3. Complete the form. Use as much detail as you can. Updates regarding your request will be posted to the issue you have created. 

## Content style guide

Read [Microsoft's Style Guide](https://learn.microsoft.com/en-us/style-guide/welcome/) to understand the guidelines for writing and formatting documents. The purpose of this style guide is to ensure consistency in the tone, voice, and structure of our documentation.

## Contribution workflow

### Fork and clone repositories

See [Fork and Pull Request Workflow](https://gist.github.com/Chaser324/ce0505fbed06b947d962)

### Report issues and bugs

Please create a new issue and provide as much deatail as possible. If you have screenshots and log files, please attach them or provide a link where they can be publically viewed.  

### Commit messages

Use Conventional Commits for structure. The commit message should be structured as follows: 

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit contains the following structural elements, to communicate intent to the consumers of your library:
1.	fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in Semantic Versioning). Append the GitHub Issue URL to the footer of the commit message. 
2.	feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning). Append the GitHub Issue URL to the footer of the commit message.
3.	BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
4.	types other than fix: and feat: are allowed, for example @commitlint/config-conventional (based on the Angular convention) recommends build:, chore:, ci:, docs:, style:, refactor:, perf:, test:, and others.
5.	footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in Semantic Versioning (unless they include a BREAKING CHANGE). A scope may be provided to a commit’s type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.


Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in Semantic Versioning (unless they include a BREAKING CHANGE). A scope may be provided to a commit’s type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.

### Branch creation

Each new fix, or feature must have it's own branch named after the feature or fix being worked on. 

### Pull requests

Use the pull request template. All new features or fixes are first merged into the `Dev` branch before being merged into `main`
