CREATE OR REPLACE PACKAGE f_polinom AS
    FUNCTION sum_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2; --функция для суммирования многочленов 

    FUNCTION sub_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2;--функция для вычитания многочленов

    FUNCTION mult_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2; --функция для умножения многочленов

    FUNCTION simple_polinom (
        v_polinom VARCHAR2
    ) RETURN VARCHAR2; --функция для упрощения многочленов

    FUNCTION pow_polinom (
        v_polinom   VARCHAR2,
        v_degree    NUMBER
    ) RETURN VARCHAR2; -- функция для возведения многочлена в степень

END f_polinom;
/

CREATE OR REPLACE PACKAGE BODY f_polinom IS

    TYPE pol IS RECORD (
        num   NUMBER(2) := 0,
        str   VARCHAR(100) := ''
    );
    TYPE polinoms IS
        TABLE OF pol;

    FUNCTION sum_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2 AS

        mas1        polinoms := polinoms();
        mas2        polinoms := polinoms();
        masres      polinoms := polinoms();
        v_first1    VARCHAR2(100);
        v_second1   VARCHAR2(100);
        res         VARCHAR2(100);
        n1          NUMBER(2);
        n2          NUMBER(2);
        idx1        NUMBER(2) := -1;
        idx2        NUMBER(2) := -1;
        b           BOOLEAN;
        bb          BOOLEAN;
    BEGIN
        v_first1 := f_polinom.simple_polinom(v_first);
        v_second1 := f_polinom.simple_polinom(v_second);
        IF ( substr(v_first1, 1, 1) != '+' AND substr(v_first1, 1, 1) != '-' ) THEN
            v_first1 := '+' || v_first1;
        END IF;

        IF ( substr(v_second1, 1, 1) != '+' AND substr(v_second1, 1, 1) != '-' ) THEN
            v_second1 := '+' || v_second1;
        END IF;

        WHILE ( idx1 != 0 ) LOOP
            idx1 := regexp_instr(substr(v_first1, 2), '\+|\*|\\|\-');
            IF ( idx1 = 0 ) THEN
                mas1.extend;
                mas1(mas1.last).str := regexp_replace(substr(v_first1, 0, length(v_first1)), '\-\d+|\+\d+|^[\w+\^\d+]]');

                mas1(mas1.last).num := regexp_replace(substr(v_first1, 0, length(v_first1)), '\w\^\d|[[:alpha:]]');

                EXIT;
            END IF;

            mas1.extend;
            mas1(mas1.last).str := regexp_replace(substr(v_first1, 0, idx1), '\-\d+|\+\d+|^[\w+\^\d+]]');

            mas1(mas1.last).num := regexp_replace(substr(v_first1, 0, idx1), '\w\^\d|[[:alpha:]]');

            v_first1 := substr(v_first1, idx1 + 1, length(v_first1));
        END LOOP;

        WHILE ( idx2 != 0 ) LOOP
            idx2 := regexp_instr(substr(v_second1, 2), '\+|\*|\\|\-');
            IF ( idx2 = 0 ) THEN
                mas1.extend;
                mas1(mas1.last).str := regexp_replace(substr(v_second1, 0, length(v_second1)), '\-\d|\+\d|^[\w+\^\d+]]');

                mas1(mas1.last).num := regexp_replace(substr(v_second1, 0, length(v_second1)), '\w\^\d|[[:alpha:]]');

                EXIT;
            END IF;

            mas1.extend;
            mas1(mas1.last).str := regexp_replace(substr(v_second1, 0, idx2), '\-\d|\+\d|^[\w+\^\d+]]');

            mas1(mas1.last).num := regexp_replace(substr(v_second1, 0, idx2), '\w\^\d|[[:alpha:]]');

            v_second1 := substr(v_second1, idx2 + 1, length(v_second1));
        END LOOP;

        FOR i IN mas1.first..mas1.last LOOP IF ( mas1(i).num >= 0 ) THEN
            res := res
                   || '+'
                   || to_char(mas1(i).num)
                   || mas1(i).str;

        ELSE
            res := res
                   || to_char(mas1(i).num)
                   || mas1(i).str;
        END IF;
        END LOOP;

        RETURN f_polinom.simple_polinom(res);
    END;

    FUNCTION sub_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2 AS

        v_first1    VARCHAR2(100);
        v_second1   VARCHAR2(100);
        idx         NUMBER(2) := 0;
    BEGIN
        v_first1 := f_polinom.simple_polinom(v_first);
        v_second1 := f_polinom.simple_polinom(v_second);
        IF ( substr(v_second1, 1, 1) != '-' ) THEN
            v_second1 := '+' || v_second1;
        END IF;

        IF ( substr(v_second1, 1, 1) = '-' ) THEN
            v_second1 := '+'
                         || substr(v_second1, 2, length(v_second1));
        ELSE
            v_second1 := '-'
                         || substr(v_second1, 2, length(v_second1));
        END IF;

        idx := 2;
        WHILE ( idx < length(v_second1) - 1 ) LOOP
            IF ( substr(v_second1, idx, 1) = '+' ) THEN
                v_second1 := substr(v_second1, 0, idx - 1)
                             || '-'
                             || substr(v_second1, idx + 1, length(v_second1));
            ELSIF ( substr(v_second1, idx, 1) = '-' ) THEN
                v_second1 := substr(v_second1, 0, idx - 1)
                             || '+'
                             || substr(v_second1, idx + 1, length(v_second1));
            ELSE
                idx := idx + 1;
                CONTINUE;
            END IF;

            idx := idx + 1;
        END LOOP;

        RETURN f_polinom.simple_polinom(f_polinom.sum_polinom(v_first1, v_second1));
    END;

    FUNCTION mult_polinom (
        v_first    VARCHAR2,
        v_second   VARCHAR2
    ) RETURN VARCHAR2 AS

        TYPE massiv IS
            TABLE OF VARCHAR2(1000);
        masiv1      massiv := massiv();
        masiv2      massiv := massiv();
        mas1        polinoms := polinoms();
        mas2        polinoms := polinoms();
        masres      polinoms := polinoms();
        res         VARCHAR2(1000);
        n1          NUMBER(3);
        n2          NUMBER(3);
        idx1        NUMBER(2) := -1;
        idx2        NUMBER(2) := -1;
        indx1       NUMBER(2) := 0;
        indx2       NUMBER(2) := 0;
        b           BOOLEAN;
        bb          BOOLEAN;
        buf         VARCHAR(1000) := '';
        v_first1    VARCHAR2(100);
        v_second1   VARCHAR2(100);
    BEGIN
        v_first1 := f_polinom.simple_polinom(v_first);
        v_second1 := f_polinom.simple_polinom(v_second);
        IF ( substr(v_first1, 1, 1) != '+' AND substr(v_first1, 1, 1) != '-' ) THEN
            v_first1 := '+' || v_first1;
        END IF;

        IF ( substr(v_second1, 1, 1) != '+' AND substr(v_second1, 1, 1) != '-' ) THEN
            v_second1 := '+' || v_second1;
        END IF;

        WHILE ( idx1 != 0 ) LOOP
            idx1 := regexp_instr(substr(v_first1, 2), '\+|\*|\\|\-');
            IF ( idx1 = 0 ) THEN
                mas1.extend;
                mas1(mas1.last).str := regexp_replace(substr(v_first1, 0, length(v_first1)), '\-\d+|\+\d+|^[\w\^\d+]]');

                mas1(mas1.last).num := regexp_replace(substr(v_first1, 0, length(v_first1)), '\w\^\d+|[[:alpha:]]');

                EXIT;
            END IF;

            mas1.extend;
            mas1(mas1.last).str := regexp_replace(substr(v_first1, 0, idx1), '\-\d+|\+\d+|^[\w+\^\d+]]');

            mas1(mas1.last).num := regexp_replace(substr(v_first1, 0, idx1), '\w\^\d|[[:alpha:]]');

            v_first1 := substr(v_first1, idx1 + 1, length(v_first1));
        END LOOP;

        WHILE ( idx2 != 0 ) LOOP
            idx2 := regexp_instr(substr(v_second1, 2), '\+|\*|\\|\-');
            IF ( idx2 = 0 ) THEN
                mas2.extend;
                mas2(mas2.last).str := regexp_replace(substr(v_second1, 0, length(v_second1)), '\-\d+|\+\d+|^[\w+\^\d+]]');

                mas2(mas2.last).num := regexp_replace(substr(v_second1, 0, length(v_second1)), '\w\^\d|[[:alpha:]]');

                EXIT;
            END IF;

            mas2.extend;
            mas2(mas2.last).str := regexp_replace(substr(v_second1, 0, idx2), '\-\d+|\+\d+|^[\w+\^\d+]]');

            mas2(mas2.last).num := regexp_replace(substr(v_second1, 0, idx2), '\w\^\d|[[:alpha:]]');

            v_second1 := substr(v_second1, idx2 + 1, length(v_second1));
        END LOOP;

        FOR i IN mas1.first..mas1.last LOOP FOR j IN mas2.first..mas2.last LOOP
            masres.extend;
            masres(masres.last).num := mas1(i).num * mas2(j).num;

            indx1 := 1;
            indx2 := 1;
            WHILE ( indx1 <= length(mas1(i).str) ) LOOP IF ( NOT regexp_like(substr(mas1(i).str, indx1, 2), '\w\^') ) THEN
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 1);

                indx1 := indx1 + 1;
            ELSIF ( length(mas1(i).str) - 4 = indx1 ) THEN
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 3);

                EXIT;
            ELSE
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 3);

                indx1 := indx1 + 3;
            END IF;
            END LOOP;

            WHILE ( indx2 <= length(mas2(j).str) ) LOOP IF ( NOT regexp_like(substr(mas2(j).str, indx2, 2), '\w\^') ) THEN
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas2(j).str, indx2, 1);

                indx2 := indx2 + 1;
            ELSIF ( length(mas2(j).str) - 4 = indx2 ) THEN
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas2(j).str, indx2, 3);

                EXIT;
            ELSE
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas2(j).str, indx2, 3);

                indx2 := indx2 + 3;
            END IF;
            END LOOP;

            buf := '';
            FOR k IN masiv1.first..masiv1.last LOOP FOR n IN masiv2.first..masiv2.last LOOP
                IF ( masiv1(k) = '' OR masiv2(n) = '' ) THEN
                    CONTINUE;
                END IF;

                IF ( masiv1(k) = masiv2(n) ) THEN
                    IF ( length(masiv1(k)) = 1 ) THEN
                        buf := buf
                               || masiv1(k)
                               || '^2';
                        masiv1(k) := '';
                    ELSE
                        buf := buf
                               || ( substr(masiv1(k), 1, 2) )
                               || to_char(to_number(substr(masiv1(k), 3, 1)) + to_number(substr(masiv2(n), 3, 1)));

                        masiv1(k) := '';
                    END IF;

                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv2(n), 1, 1) AND length(masiv1(k)) > 1 AND length(masiv2(n)) = 1 ) THEN
                    buf := buf
                           || substr(masiv1(k), 1, 2)
                           || to_char(to_number(substr(masiv1(k), 3, 1)) + 1);

                    masiv1(k) := '';
                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv2(n), 1, 1) AND length(masiv2(n)) > 1 AND length(masiv1(k)) = 1 ) THEN
                    buf := buf
                           || substr(masiv2(n), 1, 2)
                           || to_char(to_number(substr(masiv2(n), 3, 1)) + 1);

                    masiv1(k) := '';
                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv2(n), 1, 1) AND length(masiv2(n)) > 1 AND length(masiv1(k)) > 1 ) THEN
                    buf := buf
                           || substr(masiv2(n), 1, 2)
                           || to_char(to_number(substr(masiv2(n), 3, 1)) + substr(masiv1(k), 3, 1));

                    masiv1(k) := '';
                ELSE
                    buf := buf || masiv1(k);
                    masiv1(k) := '';
                    CONTINUE;
                END IF;

                masiv2(n) := '';
            END LOOP;
            END LOOP;

            FOR k IN masiv2.first..masiv2.last LOOP buf := buf || masiv2(k);
            END LOOP;

            masres(masres.last).str := buf;
            masiv1.DELETE;
            masiv2.DELETE;
        END LOOP;
        END LOOP;

        FOR i IN masres.first..masres.last LOOP IF ( masres(i).num > 0 ) THEN
            res := res
                   || '+'
                   || to_char(masres(i).num)
                   || masres(i).str;

        ELSE
            res := res
                   || to_char(masres(i).num)
                   || masres(i).str;
        END IF;
        END LOOP;

        RETURN f_polinom.simple_polinom(res);
    END;

    FUNCTION simple_polinom (
        v_polinom VARCHAR2
    ) RETURN VARCHAR2 AS

        TYPE massiv IS
            TABLE OF VARCHAR2(1000);
        masiv1       massiv := massiv();
        masiv2       massiv := massiv();
        buf          VARCHAR2(100);
        buff         VARCHAR2(100);
        bufff        VARCHAR2(100);
        mas1         polinoms := polinoms();
        res1         VARCHAR2(100) := '';
        idx          NUMBER(2) := -1;
        idx1         NUMBER(2) := -1;
        v_polinom1   VARCHAR2(100);
        chk          BOOLEAN := true;
        indx1        NUMBER(2) := 0;
        indx2        NUMBER(2) := 0;
        chk1         BOOLEAN := true;
    BEGIN
        v_polinom1 := v_polinom;
        IF ( substr(v_polinom1, 1, 1) != '+' AND substr(v_polinom1, 1, 1) != '-' ) THEN
            v_polinom1 := '+' || v_polinom1;
        END IF;

        WHILE ( regexp_like(v_polinom1, '.+\(.+\).?') ) LOOP
            buf := substr(v_polinom1, regexp_instr(v_polinom1, '\(') + 1, regexp_instr(v_polinom1, '\)') - regexp_instr(v_polinom1
            , '\(') - 1);

            IF ( substr(buf, 1, 1) != '+' AND substr(buf, 1, 1) != '-' ) THEN
                buf := '+' || buf;
            END IF;

            WHILE ( idx != 0 ) LOOP
                idx := regexp_instr(substr(buf, 2), '\+|\*|\\|\-');
                IF ( idx = 0 ) THEN
                    mas1.extend;
                    mas1(mas1.last).str := regexp_replace(substr(buf, 1, length(buf)), '\-\d+|\+\d+|^[\w+\^\d+]]');

                    mas1(mas1.last).num := regexp_replace(substr(buf, 1, length(buf)), '\w\^\d|[[:alpha:]]');

                    EXIT;
                END IF;

                mas1.extend;
                mas1(mas1.last).str := regexp_replace(substr(buf, 0, idx), '\-\d+|\+\d+|^[\w+\^\d+]]');

                mas1(mas1.last).num := regexp_replace(substr(buf, 0, idx), '\w\^\d|[[:alpha:]]');

                buf := substr(buf, idx + 1, length(buf));
            END LOOP;

            IF regexp_instr(v_polinom1, '\+.+\(|\-.+\(') != 0 THEN
                idx := regexp_instr(v_polinom1, '\+.+\(|\-.+\(');
                buff := substr(v_polinom1, idx - 1, regexp_instr(v_polinom1, '\(') - idx);

            ELSIF regexp_instr(v_polinom1, '\).+\+|\).+\-') != 0 THEN
                idx := regexp_instr(v_polinom1, '\).+\+|\).+\-');
                buff := substr(v_polinom1, idx + 1, regexp_instr(substr(v_polinom1, idx + 1, length(v_polinom) - idx), '\+|\-') -
                1);

            ELSE
                idx := regexp_instr(v_polinom1, '\).+');
                buff := substr(v_polinom1, idx + 1, length(v_polinom1) - idx);

            END IF;

            FOR i IN mas1.first..mas1.last LOOP
                IF ( buff = '' OR buff IS NULL ) THEN
                    CONTINUE;
                END IF;
                bufff := to_char(mas1(i).num)
                         || mas1(i).str;

                res1 := res1
                        || f_polinom.mult_polinom(bufff, buff);
            END LOOP;

            IF regexp_instr(v_polinom1, '\+.+\(|\-.+\(') != 0 THEN
                IF regexp_instr(v_polinom1, '\).+') = 0 OR regexp_instr(v_polinom1, '\+.+\(|\-.+\(') < regexp_instr(v_polinom1, '\).+'
                ) THEN
                    v_polinom1 := substr(v_polinom1, 0, idx - 1)
                                  || substr(v_polinom1, regexp_instr(v_polinom1, '\)') + 1, length(v_polinom1) - regexp_instr(v_polinom1
                                  , '\)'));

                ELSE
                    idx := regexp_instr(v_polinom1, '\(.+\).+\+|\(.+\).+\-|\(.+\).+');
                    idx1 := regexp_instr(v_polinom1, '\).+');
                    v_polinom1 := substr(v_polinom1, 0, idx - 2)
                                  || substr(v_polinom1, idx1 + length(buff) + 1, length(v_polinom1) - idx1 - length(buff) + 1);

                END IF;
            ELSE
                idx := regexp_instr(v_polinom1, '\(.+\).+\+|\(.+\).+\-|\(.+\).+');
                idx1 := regexp_instr(v_polinom1, '\).+');
                v_polinom1 := substr(v_polinom1, 0, idx - 2)
                              || substr(v_polinom1, idx1 + length(buff) + 1, length(v_polinom1) - idx1 - length(buff) + 1);

            END IF;

            v_polinom1 := v_polinom1 || res1;
            mas1.DELETE;
            idx := -1;
            idx1 := -1;
            res1 := '';
        END LOOP;

        idx := -1;
        mas1.DELETE;
        IF ( substr(v_polinom1, 1, 1) != '+' AND substr(v_polinom1, 1, 1) != '-' ) THEN
            v_polinom1 := '+' || v_polinom1;
        END IF;

        WHILE ( idx != 0 ) LOOP
            idx := regexp_instr(substr(v_polinom1, 2), '\+|\*|\\|\-');
            IF ( idx = 0 ) THEN
                mas1.extend;
                mas1(mas1.last).str := regexp_replace(substr(v_polinom1, 0, length(v_polinom1)), '\-\d+|\+\d+|^[\w+\^\d+]]');

                mas1(mas1.last).num := regexp_replace(substr(v_polinom1, 0, length(v_polinom1)), '\w\^\d|[[:alpha:]]');

                EXIT;
            END IF;

            mas1.extend;
            mas1(mas1.last).str := regexp_replace(substr(v_polinom1, 0, idx), '\-\d+|\+\d+|^[\w+\^\d+]]');

            mas1(mas1.last).num := regexp_replace(substr(v_polinom1, 0, idx), '\w\^\d|[[:alpha:]]');

            v_polinom1 := substr(v_polinom1, idx + 1, length(v_polinom1));
        END LOOP;

        FOR i IN mas1.first..mas1.last LOOP
            indx1 := 1;
            IF ( mas1(i).str IS NULL ) THEN
                CONTINUE;
            END IF;
            WHILE ( indx1 <= length(mas1(i).str) ) LOOP IF ( NOT regexp_like(substr(mas1(i).str, indx1, 2), '\w\^') ) THEN
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 1);

                indx1 := indx1 + 1;
            ELSE
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 3);

                indx1 := indx1 + 3;
            END IF;
            END LOOP;

            mas1(i).str := '';
            FOR k IN masiv1.first..masiv1.last LOOP FOR n IN k..masiv1.last LOOP
                IF ( n = k ) THEN
                    CONTINUE;
                END IF;
                IF ( masiv1(n) IS NULL OR masiv1(k) IS NULL ) THEN
                    CONTINUE;
                END IF;

                IF ( masiv1(k) = masiv1(n) ) THEN
                    IF ( length(masiv1(k)) = 1 ) THEN
                        masiv1(k) := masiv1(k)
                                     || '^2';
                    ELSE
                        masiv1(k) := ( substr(masiv1(k), 1, 2) )
                                     || to_char(to_number(substr(masiv1(k), 3, 1)) + to_number(substr(masiv1(n), 3, 1)));
                    END IF;
                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv1(n), 1, 1) AND length(masiv1(k)) > 1 AND length(masiv1(n)) = 1 ) THEN
                    masiv1(k) := substr(masiv1(k), 1, 2)
                                 || to_char(to_number(substr(masiv1(k), 3, 1)) + 1);
                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv1(n), 1, 1) AND length(masiv1(n)) > 1 AND length(masiv1(k)) = 1 ) THEN
                    masiv1(k) := substr(masiv1(n), 1, 2)
                                 || to_char(to_number(substr(masiv1(n), 3, 1)) + 1);
                ELSIF ( substr(masiv1(k), 1, 1) = substr(masiv1(n), 1, 1) AND length(masiv1(n)) > 1 AND length(masiv1(k)) > 1 ) THEN
                    masiv1(k) := substr(masiv1(n), 1, 2)
                                 || to_char(to_number(substr(masiv1(n), 3, 1)) + substr(masiv1(k), 3, 1));
                ELSE
                    CONTINUE;
                END IF;

                masiv1(n) := '';
            END LOOP;
            END LOOP;

            FOR k IN masiv1.first..masiv1.last LOOP mas1(i).str := mas1(i).str
                                                                   || masiv1(k);
            END LOOP;

            masiv1.DELETE;
        END LOOP;

        indx1 := 0;
        FOR i IN mas1.first..mas1.last LOOP FOR j IN i..mas1.last LOOP
            chk := true;
            masiv1.DELETE;
            masiv2.DELETE;
            indx1 := 1;
            indx2 := 1;
            IF ( mas1(i).str IS NULL OR mas1(j).str IS NULL ) THEN
                CONTINUE;
            END IF;

            IF ( i = j ) THEN
                CONTINUE;
            END IF;
            IF ( length(mas1(i).str) != length(mas1(j).str) ) THEN
                CONTINUE;
            END IF;

            WHILE ( indx1 <= length(mas1(i).str) ) LOOP IF ( NOT regexp_like(substr(mas1(i).str, indx1, 2), '\w\^') ) THEN
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 1);

                indx1 := indx1 + 1;
            ELSIF ( indx1 = length(mas1(i).str) - 4 ) THEN
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 3);

                EXIT;
            ELSE
                masiv1.extend;
                masiv1(masiv1.last) := substr(mas1(i).str, indx1, 3);

                indx1 := indx1 + 3;
            END IF;
            END LOOP;

            WHILE ( indx2 <= length(mas1(j).str) ) LOOP IF ( NOT regexp_like(substr(mas1(j).str, indx2, 2), '\w\^') ) THEN
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas1(j).str, indx2, 1);

                indx2 := indx2 + 1;
            ELSIF ( indx2 = length(mas1(j).str) - 4 ) THEN
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas1(j).str, indx2, 3);

                EXIT;
            ELSE
                masiv2.extend;
                masiv2(masiv2.last) := substr(mas1(j).str, indx2, 3);

                indx2 := indx2 + 3;
            END IF;
            END LOOP;

            IF ( masiv1.count != masiv2.count ) THEN
                CONTINUE;
            END IF;
            FOR k IN masiv1.first..masiv1.last LOOP
                chk1 := false;
                IF ( masiv1(k) IS NULL OR masiv1(k) = '' ) THEN
                    CONTINUE;
                END IF;

                FOR e IN masiv2.first..masiv2.last LOOP IF masiv1(k) = masiv2(e) THEN
                    masiv2(e) := '';
                    chk1 := true;
                    EXIT;
                END IF;
                END LOOP;

                IF ( NOT chk1 ) THEN
                    chk := false;
                    EXIT;
                END IF;
            END LOOP;

            IF ( chk ) THEN
                mas1(i).num := mas1(i).num + mas1(j).num;

                mas1(j).str := '';
            END IF;

            chk := true;
        END LOOP;
        END LOOP;

        res1 := '';
        FOR i IN mas1.first..mas1.last LOOP
            IF ( mas1(i).str IS NULL ) THEN
                CONTINUE;
            END IF;
            IF ( mas1(i).num >= 0 ) THEN
                res1 := res1
                        || '+'
                        || to_char(mas1(i).num)
                        || mas1(i).str;

            ELSE
                res1 := res1
                        || to_char(mas1(i).num)
                        || mas1(i).str;
            END IF;

        END LOOP;

        RETURN res1;
    END;

    FUNCTION pow_polinom (
        v_polinom   VARCHAR2,
        v_degree    NUMBER
    ) RETURN VARCHAR2 AS
        res VARCHAR(100);
    BEGIN
        res := f_polinom.simple_polinom(v_polinom);
        FOR i IN 1..v_degree - 1 LOOP res := f_polinom.mult_polinom(res, v_polinom);
        END LOOP;

        RETURN f_polinom.simple_polinom(res);
    END;

END f_polinom;
/

DECLARE
    a   VARCHAR2(100);
    b   VARCHAR2(100);
BEGIN
    a := '1x^2yxyxyx';
    b := '3xy+2yz';
    dbms_output.put_line(f_polinom.sum_polinom(a, b));
    dbms_output.put_line(f_polinom.mult_polinom(a, b));
    a := '(2x^2y^3+5z^2y^2)4xyz';
    b := '-6x^2+1y+1y^2+1t^3';
    dbms_output.put_line(f_polinom.sub_polinom(a, b));
    a := '3x^0';
    b := '2x^4';
    dbms_output.put_line(f_polinom.mult_polinom(a, b));
    a := '1x+1y';
    dbms_output.put_line(f_polinom.pow_polinom(a, 2));
    a := '5x(1x+1y)+(1z+1x)5x';
    dbms_output.put_line(f_polinom.simple_polinom(a));
    a := '1x';
    b := '1y';
    dbms_output.put_line(f_polinom.mult_polinom(f_polinom.pow_polinom(f_polinom.sum_polinom(a, b), 3), '1x+1y'));

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Ничего не работает и не будет работать!!!');
END;