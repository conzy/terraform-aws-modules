# Core

Baseline configuration for an account. 

- terraform role
- IAM Acount Alias
- Account Level S3 Public Access Block

## Terraform Role Permissions

In general the role used to apply terraform needs to be extremely permissive. As it could need to create any resource type.
Typically it will need lots of IAM access, S3, VPC, Organizations etc etc, it can be a real challenge to maintain
an allow list, as every novel resource you introduce would break your automation and you would need to update the
permissions your terraform role has. As always this comes down to risk appetite, its certainly possible to craft a policy
that allows CRUD operations on a known set of resources. This [article](https://conormaher.com/crafting-least-privilege-iam-policies)
(shameless plug) covers some techniques that can help you here. Another good option is to use SCP policies
to restrict what that role can ultimately do.

For this demo we just attach a canned admin policy so we can create all kinds of resources.
