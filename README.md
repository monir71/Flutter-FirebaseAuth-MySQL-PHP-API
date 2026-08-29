# NH Garden Databse

PHP API Structure:
```
NHGarden/
│
├── android/
├── ios/
├── web/
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   └── ...
│
├── assets/
│
├── api/
│   ├── config/
│   │   └── database.php
│   │
│   ├── middleware/
│   │   └── auth_middleware.php
│   │
│   ├── add_owner.php
│   ├── update_owner.php
│   ├── delete_owner.php
│   │
│   ├── add_fund.php
│   ├── update_fund.php
│   ├── delete_fund.php
│   ├── get_funds.php
│   │
│   ├── add_expense.php
│   ├── update_expense.php
│   ├── delete_expense.php
│   ├── get_expenses.php
│   │
│   ├── add_income.php
│   ├── update_income.php
│   ├── delete_income.php
│   ├── get_incomes.php
│   │
│   ├── add_loan.php
│   ├── update_loan.php
│   ├── delete_loan.php
│   ├── get_loans.php
│   │
│   └── get_my_dashboard.php
│
├── pubspec.yaml
├── firebase_options.dart
└── README.md
```
