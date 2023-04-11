DECLARE
    TYPE rec IS RECORD (
        r     NUMBER(2),
        c     NUMBER(2),
        cnt   NUMBER(2)
    );      -- шахматная ячейка
    TYPE array_list IS
        TABLE OF rec;     --шахматная строка
    TYPE sup_array_list IS
        TABLE OF array_list;      --шахматная доска
    TYPE out_array IS
        TABLE OF VARCHAR(2);     -- вывод шахматной строки
    TYPE out_sup_array IS
        TABLE OF out_array;   -- вывод шахматной доски
    out_put_array   out_sup_array := out_sup_array();
    my_array        array_list := array_list();
    my_sup_array    sup_array_list := sup_array_list();
    res_sup_array   sup_array_list := sup_array_list();
    TYPE rec_2 IS
        TABLE OF VARCHAR2(2);
    rec_mas         rec_2 := rec_2();    --для создания первых шахматных ячеек
    str             VARCHAR2(196) := 'a1 b3 c7';         -- строка ввода
    num             NUMBER;
    cnt_goals       NUMBER := regexp_count(str, ' ');   -- число вершин, которые нужно посетить
    chk             BOOLEAN := false;
    chk2            BOOLEAN := false;
    cnt             NUMBER(8) := 2;
BEGIN
    WHILE length(str) > 0 LOOP      --цикл для создания первых комбинаций с введенными ячейками
        num :=
            CASE
                WHEN substr(str, 1, 1) = 'a' THEN
                    1
                WHEN substr(str, 1, 1) = 'b' THEN
                    2
                WHEN substr(str, 1, 1) = 'd' THEN
                    4
                WHEN substr(str, 1, 1) = 'c' THEN
                    3
                WHEN substr(str, 1, 1) = 'e' THEN
                    5
                WHEN substr(str, 1, 1) = 'f' THEN
                    6
                WHEN substr(str, 1, 1) = 'g' THEN
                    7
                WHEN substr(str, 1, 1) = 'h' THEN
                    8
            END;

        my_sup_array.extend;
        my_sup_array(my_sup_array.last) := array_list();
        my_sup_array(my_sup_array.last).extend;
        my_sup_array(my_sup_array.last)(1).r :=
            CASE substr(str, 2, 1)
                WHEN '1' THEN
                    1
                WHEN '2' THEN
                    2
                WHEN '3' THEN
                    3
                WHEN '4' THEN
                    4
                WHEN '5' THEN
                    5
                WHEN '6' THEN
                    6
                WHEN '7' THEN
                    7
                WHEN '8' THEN
                    8
            END;

        my_sup_array(my_sup_array.last)(1).c := num;
        my_sup_array(my_sup_array.last)(1).cnt := cnt_goals;
        rec_mas.extend;
        rec_mas(rec_mas.last) := substr(str, 2, 1)
                                 || to_char(num);

        str := substr(str, 4);
    END LOOP;

    WHILE true LOOP    --цикл поиска необходимых комбинаций
        FOR i IN my_sup_array.first..my_sup_array.last LOOP
            << mark >> FOR j IN 1..8 LOOP
                my_sup_array.extend;
                my_sup_array(my_sup_array.last) := my_sup_array(i);
                my_sup_array(my_sup_array.last).extend;
                my_sup_array(my_sup_array.last)(cnt).r :=
                    CASE
                        WHEN ( j = 1 OR j = 2 ) AND my_sup_array(i)(cnt - 1).r > 2 THEN
                            my_sup_array(i)(cnt - 1).r - 2
                        WHEN ( j = 3 OR j = 4 ) AND my_sup_array(i)(cnt - 1).r > 1 THEN
                            my_sup_array(i)(cnt - 1).r - 1
                        WHEN ( j = 5 OR j = 6 ) AND my_sup_array(i)(cnt - 1).r < 7 THEN
                            my_sup_array(i)(cnt - 1).r + 2
                        WHEN ( j = 7 OR j = 8 ) AND my_sup_array(i)(cnt - 1).r < 8 THEN
                            my_sup_array(i)(cnt - 1).r + 1
                    END; -- для определения всех возможных следующих позиций

                my_sup_array(my_sup_array.last)(cnt).c :=
                    CASE
                        WHEN ( j = 3 OR j = 7 ) AND my_sup_array(i)(cnt - 1).c > 2 THEN
                            my_sup_array(i)(cnt - 1).c - 2
                        WHEN ( j = 1 OR j = 5 ) AND my_sup_array(i)(cnt - 1).c > 1 THEN
                            my_sup_array(i)(cnt - 1).c - 1
                        WHEN ( j = 4 OR j = 8 ) AND my_sup_array(i)(cnt - 1).c < 7 THEN
                            my_sup_array(i)(cnt - 1).c + 2
                        WHEN ( j = 2 OR j = 6 ) AND my_sup_array(i)(cnt - 1).c < 8 THEN
                            my_sup_array(i)(cnt - 1).c + 1
                    END;

                FOR k IN 1..my_sup_array(my_sup_array.last).count - 1 LOOP IF to_char(my_sup_array(my_sup_array.last)(cnt).r)
                                                                              || to_char(my_sup_array(my_sup_array.last)(cnt).c) =
                                                                              to_char(my_sup_array(my_sup_array.last)(k).r)||
                                                                              to_char(my_sup_array(my_sup_array.last)(k).c)
                                                                              THEN -- для проверки наличия ячейки в комбинации в предыдущих ячейках
                    my_sup_array(my_sup_array.last)(cnt).cnt := my_sup_array(my_sup_array.last)(cnt - 1).cnt;

                    CONTINUE mark;
                END IF;
                END LOOP;

                my_sup_array(my_sup_array.last)(cnt).cnt := my_sup_array(my_sup_array.last)(cnt - 1).cnt;

                FOR k IN 1..rec_mas.count LOOP IF to_char(my_sup_array(my_sup_array.last)(cnt).r)
                                                  || to_char(my_sup_array(my_sup_array.last)(cnt).c) = rec_mas(k) THEN  -- если текущая ячейка – одна из необходимых
                    my_sup_array(my_sup_array.last)(cnt).cnt := my_sup_array(my_sup_array.last)(cnt - 1).cnt - 1;

                    IF my_sup_array(my_sup_array.last)(cnt).cnt = 0 -- если найдено первое решение

                     THEN
                        chk := true; -- условие выхода из цикла
                        res_sup_array.extend;
                        res_sup_array(res_sup_array.last) := my_sup_array(my_sup_array.last);
                    END IF;

                END IF;
                END LOOP;

            END LOOP mark;

            my_sup_array.DELETE(i);  -- удаление предыдущих комбинаций
        END LOOP;

        IF chk THEN
            EXIT;
        END IF;
        cnt := cnt + 1;
    END LOOP;

    FOR k IN res_sup_array.first..res_sup_array.last LOOP   --для каждой подходящей комбинации
        FOR i IN 1..8 LOOP    -- создание шаблона вывода
            out_put_array.extend;
            out_put_array(out_put_array.last) := out_array();
            FOR j IN 1..8 LOOP
                out_put_array(out_put_array.last).extend;
                out_put_array(out_put_array.last)(out_put_array(out_put_array.last).last) := '  ';

            END LOOP;

        END LOOP;

        FOR i IN res_sup_array(k).first..res_sup_array(k).last LOOP -- заполнение шаблона вывода

         IF i < 10 THEN
            out_put_array(res_sup_array(k)(i).r)(res_sup_array(k)(i).c) := '0' || i;

        ELSE
            out_put_array(res_sup_array(k)(i).r)(res_sup_array(k)(i).c) := i;
        END IF;
        END LOOP;

        FOR i IN 1..8 LOOP -- вывод
            FOR j IN 1..8 LOOP dbms_output.put('|' || out_put_array(i)(j));
            END LOOP;

            dbms_output.put('|');
            dbms_output.put_line('');
        END LOOP;

        dbms_output.put_line('                    ');
        out_put_array.DELETE;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN  -- все ошибки – некорректный ввод
        dbms_output.put_line('некорректный ввод');
END;