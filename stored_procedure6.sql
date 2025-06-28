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

-- How to call it:
SELECT give_raise(1, 10); -- Give 10% raise to employee with id 1