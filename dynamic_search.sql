DECLARE
    match_count   NUMBER(2); --число совпадений строки ввода в данной таблице в данном столбце
    query_str     VARCHAR2(400); --сформированный dynamic запрос
    l_search_text VARCHAR2(100) := 'King';--строка ввода
    cnt Varchar2(100); --индекс таблицы результатов
    Cursor res is -- отбор всех столбцов всех таблиц
        SELECT c.table_name, c.column_name, c.data_type, c.data_length
        FROM all_tab_columns c, all_objects o
        WHERE data_type in ('VARCHAR2') and c.table_name = o.object_name and Lower(o.object_type) = 'table'
        ORDER BY c.table_name; -- отсортировано
    Type mas is Table of VarChar2(100) INDEX BY VARCHAR2(100); -- таблица, которая хранит результаты работы
    masiv mas;
BEGIN
    FOR t IN res -- для каждого результата в курсоре
    LOOP
        begin
            match_count := 0;
            query_str   := 'SELECT COUNT(*) FROM ' ||t.table_name ||          --запрос, отбирающий число вхождений строки ввода в таблицах со столбцами 
                         ' WHERE to_char(' || t.column_name || ') = :1';
            EXECUTE IMMEDIATE query_str
            INTO match_count
            USING l_search_text;
            IF match_count > 0 and masiv.Exists(t.table_name) and regexp_instr(masiv(t.table_name),t.column_name)=0 THEN -- если число вхождений больше нуля, раньше данная таблица использовалась
                masiv(t.table_name):= masiv(t.table_name)||', '||t.column_name||'('||t.data_type||'('||t.data_length||'))';
            ELSIF match_count > 0 and Not masiv.Exists(t.table_name) THEN        --если число вхождений больше нуля, но данная таблица ещё не появлялась в результате
                masiv(t.table_name):= t.column_name||'('||t.data_type||'('||t.data_length||'))';
            END IF;
            Exception when others then continue;
        end;
    END LOOP;
    dbms_output.put_line('Таблица                  Список столбцов');
    cnt := masiv.FIRST; -- cnt хранит имя первой отобранной таблицы
    while (cnt is not null) loop
        dbms_output.put_line(RPAD(cnt,20,' ')||'     '||masiv(cnt)); -- вывод имени таблицы, столбца, его data_type и data_length
        cnt := masiv.NEXT(cnt); --берётся следующая таблица из прошедших отбор
    end loop;
END;