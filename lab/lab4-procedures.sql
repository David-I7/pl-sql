-- Proceduri locale
/* 1. Să se declare o procedură locală într-un bloc PL/SQL anonim prin care să se introducă în
tabelul DEP_pnu o nouă înregistrare precizând, prin intermediul parametrilor, valori pentru toate
câmpurile. Invocati procedura în cadrul blocului. Interogati tabelul DEP_pnu si apoi anulati
modificările (ROLLBACK).
*/

DECLARE
    PROCEDURE add_dep (
        dep_id dep_pnu.department_id%type,
        dep_name dep_pnu.department_name%type,
        man_id dep_pnu.manager_id%type:=NULL,
        loc_id dep_pnu.location_id%type:=NULL
    ) AS
    BEGIN 
        INSERT INTO DEP_PNU VALUES (dep_id,dep_name,man_id,loc_id);
    END;
BEGIN
    add_dep(1000,'Test 1',NULL,NULL);
    add_dep(dep_name=>'Test 2',dep_id=>1001,man_id=>NULL,loc_id=>NULL);
    add_dep(dep_name=>'Test 3',dep_id=>1002);
END;
/

select * from dep_pnu;
rollback;


/* 2. Să se declare o procedură locală care are parametrii următori:
- p_rezultat (parametru de tip IN OUT) de tipul coloanei last_name din tabelul employees;
- p_comision (parametru de tip OUT) de tipul coloanei commission_pct din employees, initializat
cu NULL;
- p_cod (parametru de tip IN) de tipul coloanei employee_id din employees, initializat cu NULL.
Dacă p_comision nu este NULL atunci în p_rezultat se va memora numele salariatului care are
salariul maxim printre salariatii având comisionul respectiv. În caz contrar, în p_rezultat se va
memora numele salariatului al cărui cod are valoarea dată la apelarea procedurii.
*/

SET SERVEROUTPUT ON

DECLARE
    v_rezultat employees.last_name%TYPE;
    PROCEDURE solution_2 (
        p_rezultat IN OUT employees.last_name%TYPE, 
        p_comision IN employees.commission_pct%TYPE := NULL,
        p_cod IN employees.employee_id%TYPE :=NULL
    ) AS
    BEGIN 
        IF p_comision IS NOT NULL THEN
          SELECT last_name into p_rezultat FROM employees where commission_pct = p_comision 
                  order by salary DESC 
                  FETCH FIRST 1 ROWS ONLY; 
          DBMS_OUTPUT.PUT_LINE('Numele salariatului care are comisionul '||p_comision||
                                ' este '||p_rezultat);
        ELSE 
            SELECT last_name INTO p_rezultat FROM EMPLOYEES WHERE employee_id = p_cod;
            DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul '||p_cod||
                                 ' este '||p_rezultat);
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('Nu am gasit angajatul cu codul sau comisionul respectiv');
    END;
BEGIN
    solution_2 (v_rezultat,0.4);
    solution_2 (v_rezultat,p_cod=>205);
    solution_2 (v_rezultat);
END;
/


-- Proceduri stocate
/* 3. Să se creeze o procedură stocată fără parametri care afisează un mesaj “Programare PL/SQL”,
ziua de astăzi în formatul DD-MONTH-YYYY si ora curentă, precum si ziua de ieri în formatul DD-MON-YYYY
*/


CREATE OR REPLACE PROCEDURE sol_3 AS
BEGIN
    dbms_output.put_line('Programare PL/SQL');
    dbms_output.put_line('Azi: ' || to_char(CURRENT_TIMESTAMP, 'DD-MONTH-YYYY HH24'));
    dbms_output.put_line('Ieri: ' || to_char(CURRENT_TIMESTAMP - 1, 'DD-MON-YYYY'));
END;
/

BEGIN 
    sol_3;
END;
/
