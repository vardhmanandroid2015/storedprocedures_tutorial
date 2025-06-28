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

-- How to use it with our employees table:
SELECT name, salary, categorize_salary(salary) as salary_category
FROM employees;