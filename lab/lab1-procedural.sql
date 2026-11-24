-- Laborator 1

SET SERVEROUTPUT ON
SET SERVEROUTPUT OFF

/* 1. Creati un bloc PL/SQL care declară 2 variabile (una de tip sir de caractere si cealaltă numerică),
initializate la declarare. Atribuiti valorile acestor variabile PLSQL unor variabile gazdă (VARIABLE)
SQL*Plus si tipăriti valorile variabilelor PL/SQL pe ecran. Executati blocul PL/SQL.
*/

VARIABLE g_nr NUMBER
VARIABLE g_sir VARCHAR2
DECLARE
    v_nr NUMBER := 20;
    v_sir VARCHAR2(256) := 'Hello World';
BEGIN
    :g_nr := v_nr;
    :g_sir := v_sir;
END;
/
PRINT g_nr
PRINT g_sir

/* 2. Creati si executati un bloc PL/SQL care cere de la tastatura 2 numere (prin variabile de substitutie
SQL* Plus). Primul numar se va imparti la al doilea, si se va adauga rezultatului cel de-al doilea
numar. Dacă al doilea număr este 0, rezultatul va fi pătratul primului număr (x**2). Rezultatul va fi
retinut intr-o variabila PL/SQL si va fi tiparit pe ecran.
*/

ACCEPT g_nr_1 PROMPT 'Introdu primul numar: '
ACCEPT g_nr_2 PROMPT 'Introdu al doilea numar: '

DECLARE
    v_rezultat NUMBER;
BEGIN
    IF &g_nr_2 = 0 THEN 
        v_rezultat := &g_nr_1 ** 2;
    ELSE v_rezultat := &g_nr_1 / &g_nr_2 + &g_nr_2;
    END IF;
    
    dbms_output.put_line('Rezultat: ' || v_rezultat);
END;
/

/* 3. Să se calculeze suma salariilor pentru un job al cărui cod este introdus de utilizator. Căutarea se va
face case-insensitive.
*/

ACCEPT g_job_id PROMPT 'Introdu id-ul jobului:'

DECLARE
    v_job_id JOBS.job_id%type := UPPER('&g_job_id'); 
    v_suma_salarii EMPLOYEES.salary%type;
BEGIN
    SELECT SUM(e.salary) into v_suma_salarii
    FROM JOBS j JOIN EMPLOYEES e on e.job_id = j.job_id
    WHERE j.job_id = v_job_id;
    
    IF v_suma_salarii IS NULL THEN
        dbms_output.put_line('Jobul nu exista sau toate salariile sunt null');
    ELSE dbms_output.put_line('Suma salariilor este: ' || v_suma_salarii);
    END IF;
END;
/

/* 4. Creati un bloc PL/SQL care calculeaza castigul total pentru un an, salariul anual si procentul care
reprezinta bonusul fiind transmise blocului PL/SQL prin variabile de substitutie SQL*Plus. Bonusul
se va introduce ca numar intreg (pentru bonus de 15% se va introduce 15). Daca salariul este null,
va fi setat la 0 inainte de a calcula castigul total. Executati blocul PL/SQL. Se va folosi functia NVL
pentru manipularea valorilor NULL.  
*/

DEFINE g_bonus = 15
DEFINE g_employee_id = 0

DECLARE
    v_bonus NUMBER(3,2) := GREATEST(0,LEAST((&g_bonus / 100),1.00));
    v_castig_total EMPLOYEES.salary%type;
    v_salariu_anual EMPLOYEES.salary%type;
    v_bonus_total NUMBER;
BEGIN
    SELECT NVL(e.salary,0) * 12 into v_salariu_anual
    FROM EMPLOYEES e
    WHERE e.employee_id = &g_employee_id;
    
    v_bonus_total := v_salariu_anual * v_bonus;
    v_castig_total := v_salariu_anual + v_bonus_total;
    
    dbms_output.put_line('Castig total: ' || v_castig_total);
    dbms_output.put_line('Salariu anual: ' || v_salariu_anual);
    dbms_output.put_line('Bonus: ' || v_bonus_total);
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Angajatul nu a fost gasit');
END;
/

/* 5. Sa se creeze un bloc PL/SQL care calculeaza si modifica valoarea comisionului pentru un angajat al
carui cod este dat de la tastatura, pe baza salariului acestuia, astfel:
- daca salariul este mai mic decat 1000$, comisionul va fi 10% din salariu;
- daca salariul ete intre 1000 si 1500$, comisionul va fi 15% din salariu;
- daca salariul depaseste 1500$, comisionul va fi 20% din salariu;
- daca salariul este NULL, comisionul va fi 0.
Modificările se fac în tabelul emp_pnu.
*/

CREATE TABLE emp_pnu AS
SELECT *
FROM employees;

ACCEPT g_employee_id PROMPT 'Intro id-ul angajatului:'
DECLARE
    v_val_comision EMP_PNU.salary%type;
BEGIN
    UPDATE EMP_PNU
    SET commission_pct = CASE WHEN salary IS NULL THEN 0 
                              WHEN salary < 1000 THEN 0.1 
                              WHEN salary BETWEEN 1000 AND 1500 THEN 0.15
                              ELSE 0.2
                         END 
    WHERE employee_id = &g_employee_id
    RETURNING NVL(salary,0) * commission_pct INTO v_val_comision;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.put_line('Angajatul nu a fost gasit');
    ELSE DBMS_OUTPUT.put_line('Comisionul lunar este ' || v_val_comision);
    END IF;
END;
/

drop table emp_pnu;

/* 6. Sa se creeze un bloc PL/SQL care selecteaza codul maxim de departament din tabelul
      DEPARTMENTS si il stocheaza intr-o variabila SQL*Plus. Se va tipari rezultatul pe ecran.  
*/

VARIABLE g_cod_dep NUMBER;
BEGIN
    SELECT MAX(department_id) INTO :g_cod_dep FROM DEPARTMENTS; 
END;
/
PRINT g_cod_dep

/* 7. Sa se creeze un bloc PL/SQL care insereaza un nou departament in tabelul DEPT_PNU. Se va
    folosi parametru de substitutie pentru numele departamentului. Codul este dat de valoarea variabilei
    calculate anterior +1. Locatia va avea valoarea null. Sa se listeze continutul tabelului DEPT_PNU. 
*/

VARIABLE g_cod_dep NUMBER;
BEGIN
    SELECT MAX(department_id) INTO :g_cod_dep FROM DEPARTMENTS; 
END;
/

CREATE TABLE dep_pnu AS
SELECT * FROM DEPARTMENTS;

DEFINE g_nume_dep = 'Departament nou'
BEGIN
    INSERT INTO dep_pnu values (:g_cod_dep + 1, '&g_nume_dep', null, null);
END;
/

SELECT * FROM dep_pnu;
DROP TABLE dep_pnu;

/* 8. Sa se creeze un bloc PL/SQL care reactualizeaza locatia pentru un departament existent (în tabelul
DEPT_PNU). Se vor folosi parametri de substitutie pentru numarul departamentului si locatia
acestuia. Sa se listeze codul, numele si locatia pentru departamentul reactualizat.
*/

CREATE TABLE dep_pnu AS
SELECT * FROM DEPARTMENTS;

DEFINE g_cod_dep = 270
DEFINE g_loc_noua = 1900

DECLARE 
    v_cod_dep DEP_PNU.department_id%type;
    v_loc_dep DEP_PNU.location_id%type;
    v_dep_nume DEP_PNU.department_name%type;
BEGIN
    -- Ar trebui, in mod normal, sa prindem eroarea incalcarii constrangerii foreign key pe colana location_id  
    UPDATE dep_pnu
    SET location_id = &g_loc_noua
    WHERE department_id = &g_cod_dep
    RETURNING department_id, department_name, location_id into v_cod_dep, v_dep_nume, v_loc_dep;
    
    DBMS_OUTPUT.PUT_LINE('Cod departament: ' || v_cod_dep);
    DBMS_OUTPUT.PUT_LINE('Nume departament: ' || v_dep_nume);
    DBMS_OUTPUT.PUT_LINE('Locatie departament: ' || v_loc_dep);
END;
/

DROP TABLE dep_pnu;

/* 9. Sa se creeze un bloc PL/SQL care sterge departamentul creat la exercitiul 7. Se va folosi un
parametru de substitutie pentru numarul departamentului. Se va tipari pe ecran numarul de linii
afectate. Ce se intampla daca se introduce un cod de departament care nu exista?
*/

-- Vom avea 0 linii afectate daca introducem un cod de departament care nu exista

VARIABLE g_cod_dep NUMBER;
BEGIN
    SELECT MAX(department_id) INTO :g_cod_dep FROM DEPARTMENTS; 
END;
/

CREATE TABLE dep_pnu AS
SELECT * FROM DEPARTMENTS;

DEFINE g_nume_dep = 'Departament nou'
BEGIN
    INSERT INTO dep_pnu values (:g_cod_dep + 1, '&g_nume_dep', null, null);
END;
/

DEFINE g_cod_stergere = 271

BEGIN
    DELETE FROM dep_pnu
    WHERE department_id = &g_cod_stergere;
    
    dbms_output.put_line('Numar linii afectate: ' || SQL%ROWCOUNT);
END;
/

drop table dep_pnu;

