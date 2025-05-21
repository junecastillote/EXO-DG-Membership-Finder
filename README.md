# EXO DG Membership Finder

PowerShell script to check Exchange Online Distribution Group membership for a specified user.

## 📋 Description

`Find-ExoDGMembership.ps1` is a PowerShell script designed to identify the distribution groups in Exchange Online where a particular user (identified by their email address) is a member.

You can either:

- Check membership against **all** distribution groups, or
- Limit the check to a specified list of distribution group email addresses.

Results can be exported to a CSV file and optionally returned to the console.

> **Note**: Requires an active connection to Exchange Online using `Connect-ExchangeOnline`.

---

## ✅ Features

- Query all distribution groups or a specified subset.
- Export results to a timestamped or user-defined CSV file.
- Optionally output results directly to the console.
- Uses `Get-DistributionGroup` and `Get-DistributionGroupMember`.

---

## 💻 Usage

### Syntax

```PowerShell
.\Find-ExoDGMembership.ps1 -MemberEmailAddress <string> [-DistributionGroupEmailAddress <string[]>] [-OutCsvFile <string>] [-ReturnResult]
```

### Parameters

| Name                            | Required | Description                                                                                                           |
| ------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------- |
| `MemberEmailAddress`            | Yes      | The primary SMTP address of the user to check.                                                                        |
| `DistributionGroupEmailAddress` | No       | Array of distribution group email addresses to filter the search. If omitted, all groups will be checked.             |
| `OutCsvFile`                    | No       | Full path to the output CSV file. If not provided, a file will be created with a timestamp in the script's directory. |
| `ReturnResult`                  | No       | Switch to also output the result(s) to the console.                                                                   |

---

## 📦 Examples

### 🔍 Check all distribution groups for a user

```PowerShell
.\Find-ExoDGMembership.ps1 -MemberEmailAddress "user@example.com"
```

### 🔍 Check membership in specific groups only

```PowerShell
.\Find-ExoDGMembership.ps1 -MemberEmailAddress "user@example.com" -DistributionGroupEmailAddress "group1@example.com","group2@example.com"
```

### 💾 Export results to a specific CSV file

```PowerShell
.\Find-ExoDGMembership.ps1 -MemberEmailAddress "user@example.com" -OutCsvFile "C:\Reports\Membership.csv"
```

### 🖥️ Display matching groups in the console as well

```PowerShell
.\Find-ExoDGMembership.ps1 -MemberEmailAddress "user@example.com" -ReturnResult
```

---

## 📌 Requirements

- PowerShell 5.1 or later
- Exchange Online PowerShell module (`ExchangeOnlineManagement`)
- An active connection to Exchange Online (`Connect-ExchangeOnline`)

---

## ⚠️ Notes

- The script uses `PrimarySmtpAddress` to compare membership.
- If no matches are found, an informational message will be displayed.
- The script creates a timestamped CSV in the script directory by default.

---

## 📄 License

MIT License – see [LICENSE](LICENSE) file for details.
