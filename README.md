# PostgreSQL Stored Procedures & Triggers: A Beginner's Guide

This guide provides a beginner-friendly introduction to creating and using stored procedures (as functions) and triggers in PostgreSQL. It covers basic syntax, common patterns, and practical examples, from simple "Hello World" functions to complex data auditing with triggers.

## Prerequisites

Make sure you have PostgreSQL installed and can connect to a database. You can use pgAdmin, the `psql` command line, or any other PostgreSQL client.

> **Note on Functions vs. Procedures:** In PostgreSQL, stored logic that returns a value is created using `CREATE FUNCTION`. While newer versions of PostgreSQL have a `CREATE PROCEDURE` command for routines that do not return values, the use of functions is far more common and is the focus of this guide.

## Stored Procedure (Function) Structure

Here are the key components of a PostgreSQL function written in the `plpgsql` language.

### Key Takeaways

1.  **`CREATE OR REPLACE FUNCTION`**: Creates a new function or updates an existing one.
2.  **`function_name(parameters)`**: Names the function and defines its input parameters.
3.  **`RETURNS type`**: Declares the data type of the value that the function will return.
4.  **`AS $$`**: Starts the function body using dollar quoting, which helps avoid issues with single quotes inside the function logic.
5.  **`BEGIN...END;`**: Wraps the block of executable SQL and procedural code.
6.  **`RETURN value;`**: Sends a value back to the caller.
7.  **`$$ LANGUAGE plpgsql;`**: Closes the function body and specifies `plpgsql` as the programming language.

### Basic Syntax

```sql
CREATE OR REPLACE FUNCTION function_name(parameter_list)
RETURNS return_type AS $$
BEGIN
    -- Your logic here
    RETURN something;
END;
$$ LANGUAGE plpgsql;
```

---

## Complete Examples

### 1. Basic Function with Parameters

This example shows a complete function with line-by-line explanations.

```sql
-- Line 1: Create a function named 'calculate_discount' that takes two parameters
CREATE OR REPLACE FUNCTION calculate_discount(original_price NUMERIC, discount_percent INTEGER)
-- Line 2: Declare that the function will return a decimal number and start the function body
RETURNS NUMERIC AS $$
-- Line 3: Begin the executable code block
BEGIN
    -- Line 4-5: Our logic - calculate and return the discounted price
    -- This returns the original price minus the discount amount
    RETURN original_price - (original_price * discount_percent / 100);
-- Line 6: End the executable code block
END;
-- Line 7: Close the function body and specify it's written in plpgsql
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT calculate_discount(150.00, 10); -- 10% discount on 150.00
```

**Output:** `135.00`

### 2. Simple "Hello World" Function

A function with no parameters that returns a static text value.

```sql
-- Create a simple function that returns a greeting
CREATE OR REPLACE FUNCTION say_hello()
RETURNS TEXT AS $$
BEGIN
    RETURN 'Hello, World!';
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT say_hello();
```

**Output:** `Hello, World!`

### 3. Function with Parameters

This function takes a `TEXT` input and includes it in the returned string.

```sql
-- Function that takes a name and returns a personalized greeting
CREATE OR REPLACE FUNCTION greet_user(user_name TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN 'Hello, ' || user_name || '! Welcome to PostgreSQL!';
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT greet_user('Alice');
SELECT greet_user('Bob');
```

**Output:**

```
Hello, Alice! Welcome to PostgreSQL!
Hello, Bob! Welcome to PostgreSQL!
```

### 4. Mathematical Calculations

A simple function to perform a mathematical calculation.

```sql
-- Function to calculate the area of a circle
CREATE OR REPLACE FUNCTION calculate_circle_area(radius NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN 3.14159 * radius * radius;
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT calculate_circle_area(5);
SELECT calculate_circle_area(10.5);
```

### 5. Working with Database Tables

Functions can query data from your tables. First, let's set up a sample table.

**Setup:**

```sql
-- Create a sample employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary NUMERIC(10,2),
    department VARCHAR(50)
);

-- Insert some sample data
INSERT INTO employees (name, salary, department) VALUES
('John Doe', 50000, 'IT'),
('Jane Smith', 60000, 'HR'),
('Bob Johnson', 55000, 'IT'),
('Alice Brown', 70000, 'Finance');
```

**Function:**

```sql
-- Function to get employee count by department
CREATE OR REPLACE FUNCTION get_employee_count_by_dept(dept_name TEXT)
RETURNS INTEGER AS $$
DECLARE
    emp_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE department = dept_name;

    RETURN emp_count;
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT get_employee_count_by_dept('IT');
SELECT get_employee_count_by_dept('HR');
```

### 6. Function with Conditional Logic

Use `IF/ELSIF/ELSE` to implement business rules.

```sql
-- Function to categorize salary levels
CREATE OR REPLACE FUNCTION categorize_salary(emp_salary NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF emp_salary < 50000 THEN
        RETURN 'Low';
    ELSIF emp_salary >= 50000 AND emp_salary < 65000 THEN
        RETURN 'Medium';
    ELSE
        RETURN 'High';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

**How to use it with our table:**

```sql
SELECT name, salary, categorize_salary(salary) as salary_category
FROM employees;
```

### 7. Function that Updates Data

Functions can also perform `UPDATE`, `INSERT`, or `DELETE` operations. This example gives an employee a raise.

```sql
-- Function to give a percentage raise to an employee
CREATE OR REPLACE FUNCTION give_raise(emp_id INTEGER, raise_percentage NUMERIC)
RETURNS TEXT AS $$
DECLARE
    old_salary NUMERIC;
    new_salary NUMERIC;
    emp_name TEXT;
BEGIN
    -- Get current salary and name
    SELECT salary, name INTO old_salary, emp_name
    FROM employees
    WHERE id = emp_id;

    -- Check if employee exists
    IF old_salary IS NULL THEN
        RETURN 'Employee not found';
    END IF;

    -- Calculate new salary
    new_salary := old_salary * (1 + raise_percentage / 100);

    -- Update the salary
    UPDATE employees
    SET salary = new_salary
    WHERE id = emp_id;

    RETURN emp_name || ' salary updated from ' || old_salary || ' to ' || new_salary;
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
-- Give a 10% raise to employee with id 1
SELECT give_raise(1, 10);
```

### 8. Function Returning Multiple Rows (a Table)

You can return a result set that acts like a temporary table.

```sql
-- Function that returns all employees with salary above a threshold
CREATE OR REPLACE FUNCTION get_high_earners(min_salary NUMERIC)
RETURNS TABLE(emp_name TEXT, emp_salary NUMERIC, emp_dept TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT name, salary, department
    FROM employees
    WHERE salary >= min_salary
    ORDER BY salary DESC;
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT * FROM get_high_earners(55000);
```

### 9. Function with Exception Handling

Handle potential errors gracefully using an `EXCEPTION` block.

```sql
-- Function to safely divide two numbers
CREATE OR REPLACE FUNCTION safe_divide(numerator NUMERIC, denominator NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    IF denominator = 0 THEN
        RAISE EXCEPTION 'Division by zero is not allowed';
    END IF;
    RETURN numerator / denominator;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred: %', SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

**How to call it:**

```sql
SELECT safe_divide(10, 2); -- Returns 5
SELECT safe_divide(10, 0); -- Raises an exception notice and returns NULL
```

---

## Advanced Topic: Automating Logic with Triggers

A trigger is a special type of function that is automatically executed when a specific database event (`INSERT`, `UPDATE`, `DELETE`) occurs on a table. This is extremely useful for tasks like auditing, validation, or maintaining data integrity.

This example creates a trigger that logs every salary change into an audit table.

### Step 1: Create the Necessary Tables

We need our `employees` table and a new table to store the audit logs.

```sql
-- Create the employees table if it doesn't exist
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    department VARCHAR(50)
);
COMMENT ON TABLE employees IS 'Stores employee information.';

-- Create the salary_audit_log table if it doesn't exist
CREATE TABLE IF NOT EXISTS salary_audit_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    old_salary NUMERIC(10, 2),
    new_salary NUMERIC(10, 2) NOT NULL,
    change_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
COMMENT ON TABLE salary_audit_log IS 'Logs changes to employee salaries.';

-- Insert some sample data, avoiding duplicates if script is run again
INSERT INTO employees (name, salary, department) VALUES
('John Doe', 50000.00, 'IT'),
('Jane Smith', 60000.00, 'HR'),
('Bob Johnson', 55000.00, 'IT')
ON CONFLICT (id) DO NOTHING;
```

### Step 2: Define the Trigger Function

This function contains the logic to be executed. It returns a special `TRIGGER` type.

```sql
-- This function will be executed by the trigger to log salary changes.
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new record into the audit log table using OLD and NEW special variables
    -- OLD contains the row data *before* the update
    -- NEW contains the row data *after* the update
    INSERT INTO salary_audit_log (employee_id, old_salary, new_salary, change_date)
    VALUES (OLD.id, OLD.salary, NEW.salary, NOW());

    -- For an AFTER trigger, returning NEW is standard practice.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_salary_change() IS 'Trigger function to log salary changes in the salary_audit_log table.';
```

### Step 3: Create the Trigger

This statement links the function to the table and the event.

```sql
-- This statement links the 'log_salary_change' function to the 'employees' table.
CREATE TRIGGER salary_change_audit
-- The trigger fires AFTER an UPDATE, only if the 'salary' column was changed.
AFTER UPDATE OF salary ON employees
-- The trigger executes once for each row affected by the UPDATE.
FOR EACH ROW
-- This is the function to call.
EXECUTE FUNCTION log_salary_change();

COMMENT ON TRIGGER salary_change_audit ON employees IS 'Audits salary changes by logging them into the salary_audit_log table.';
```

### Step 4: Test the Trigger

Now, when we update a salary, a log entry will be created automatically.

```sql
-- Action: Update John Doe's salary. This will fire the trigger.
UPDATE employees
SET salary = 52000.00
WHERE name = 'John Doe';

-- Verification: Check the audit log to see the new entry.
SELECT employee_id, old_salary, new_salary, change_date
FROM salary_audit_log;
```

**Expected Audit Log Output:**

| employee_id | old_salary | new_salary | change_date                     |
|-------------|------------|------------|---------------------------------|
| 1           | 50000.00   | 52000.00   | _[timestamp of the update]_     |

---

## Usage Guidelines

### When to Use Stored Procedures

Use stored procedures when you need to:

1.  **Encapsulate Complex Business Logic**: Reuse complex calculations or business rules across multiple applications.
2.  **Improve Performance**: Reduce network traffic by executing multiple SQL statements on the server in a single call.
3.  **Maintain Data Integrity**: Ensure complex, multi-step operations are atomic (all or nothing) and consistent.
4.  **Centralize Logic**: Keep business logic in one place (the database) rather than scattered across different applications.
5.  **Enhance Security**: Control data access through procedure parameters and permissions, rather than granting direct table access to users.

### Advantages and Disadvantages

#### Advantages

-   **Performance**: Compiled once and stored, leading to faster execution for repeated calls.
-   **Reduced Network Traffic**: Multiple operations can be performed in a single function call.
-   **Security**: Provides an abstraction layer over the underlying data tables.
-   **Maintainability**: Change logic in one place, and all applications using it are updated.
-   **Data Integrity**: Enforces business rules consistently.

#### Disadvantages

-   **Database Vendor Lock-in**: Code is written in a specific SQL dialect (e.g., `plpgsql`) and is not easily portable to other database systems like MySQL or SQL Server.
-   **Debugging Complexity**: Debugging database code can be harder than application code.
-   **Version Control**: Integrating database scripts into application version control systems (like Git) can be more complex.
-   **Testing**: Unit testing stored procedures can be more difficult than testing application code.

### Best Practices

1.  **Use Descriptive Names**: `calculate_employee_bonus()` is better than `calc_bonus()`.
2.  **Handle Exceptions**: Always consider what could go wrong and use `EXCEPTION` blocks.
3.  **Document Your Functions**: Use comments (`--`) to explain complex logic.
4.  **Keep It Simple**: Avoid putting too much unrelated logic in a single function.
5.  **Use Parameters Wisely**: Make functions flexible but not overly complex with too many parameters.
6.  **Return Meaningful Values**: The return value should help the caller understand what happened (e.g., return a status text or a boolean).

### Common Patterns

-   **Validation Function**: A function that checks if data conforms to a rule and returns `BOOLEAN`.
    ```sql
    CREATE OR REPLACE FUNCTION is_valid_email(email_address TEXT)
    RETURNS BOOLEAN AS $$
    BEGIN
        -- Use a regular expression to validate the email format
        RETURN email_address ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    END;
    $$ LANGUAGE plpgsql;
    ```

-   **Audit Function**: A trigger function that logs changes to a table.
    > The detailed trigger example above is a complete, practical implementation of this pattern.

## Next Steps

1.  **Practice** with these examples in your own database.
2.  **Modify** them to suit your own needs and ideas.
3.  **Learn more about triggers** and how they can automate database tasks.
4.  **Explore** PostgreSQL's vast library of built-in functions.
5.  **Study advanced topics** like cursors, dynamic SQL, and different procedural languages.

Remember: Start simple and gradually build complexity as you become more comfortable with the syntax and concepts