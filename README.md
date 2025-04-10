# Řešení

    - [Dokumentace vytvořené DBT pipeline](http://book-recommend-dbt-doc.s3-website.eu-north-1.amazonaws.com)
    - [Evidence BI frontend](http://book-recommend.s3-website.eu-north-1.amazonaws.com)

# Poznámky k výchozímu Python kódu

Kód po spuštění padá. Využití knihovny Pandas pro data engineering považuji za poněkud riskantní. Data jsou sice malá, ale je otázka, zda by se v produkci nemohla objevit data, která by přesahovala velikost hlavní paměti.  
Navíc se provádějí relativně velké manipulace s daty, které bych raději viděl v nějakém data processing enginu, jako je Spark, DuckDB nebo něco podobného.

V kódu a datech je několik problémů z pohledu kvality dat:
1. `ratings = ratings[ratings['Book-Rating']!=0]` – je lepší filtrovat na základě toho, co chceme, a ne na základě toho, co nechceme.
2. `books = pd.read_csv('BX-Books.csv',  encoding='cp1251', sep=';', on_bad_lines='skip')`  
    - Tiché přeskakování chybných řádků není vhodné.  
    - Vstupní soubory mají předdefinované kódování, které by ideálně mělo být součástí vstupu.
3. V knihách se vyskytují knihy se stejným názvem, ale různým `ISBN`. Jedná se o stejné knihy?
4. `JOIN` tabulek na základě `book_title` místo `ISBN` je poněkud podivný – to souvisí s předchozí poznámkou.
5. V datech chybí informace o tom, kdy a odkud byla data nahrána.
6. Mnoho recenzí odkazuje na neexistující knihy.
7. Některá `ISBN` jsou uppercase, jiná lowercase. Navíc `ISBN` občas obsahují neplatné znaky. Před spojením `books` a `ratings` by se tedy `ISBN` měla normalizovat.
8. Některé knihy se stejným `ISBN` se v `books` opakují (a jedna dokonce s jiným názvem). Je potřeba provést deduplikaci.
9. Ve výsledku se objevují knihy, které byly hodnoceny méně než osmi různými lidmi, kteří četli "Pána prstenů". Je to způsobeno tím, že někteří hodnotili knihu vícekrát.
10. Ke kódu by bylo vhodné připojit dokumentaci ke spuštění (stačí `README.md`) a `requirements.txt`.
11. Z pohledu fungování vyhledávání se mi příliš nelíbí ta pevně daná hodnota 8. Nejsem úplně data analytik, ale při testování nebylo úplně lehké nalézt knihy, které měly dostatek společných čtenářů. 

# Moje řešení

Řešení jsem přepracoval na ELT pomocí DBT. V rámci DBT projektu jsem odstranil výše popisované problémy dat, pokud to bylo možné. Zkoušel jsem také dohledat neexistující recenzované knihy ve třech externích datových kolekcích, ale neúspěšně.

1. Data jsou stažena pomocí Python skriptu `download_data.py` z S3 úložiště a uložena do lokální DuckDB databáze (`reports/sources/books/book_rating.duckdb`).
2. Nastavení zdrojů dat, jejich parametrů, profil i použitá databáze jsou definovány v souboru `.env`.
3. Součástí je `Makefile`, který obsahuje tři hlavní targets:

    a) `download` – stažení CSV a uložení do databáze  
    b) `dbt-run` – spuštění DBT  
    c) `evidence` – sestavení reportu pomocí Evidence
4. CSV data jsou stažena z mého S3 bucketu, kde jsem CSV data v původní podobě umístil: https://book-recommendation.s3.amazonaws.com/
5. Raw CSV data jsou po stažení uložena do lokální DuckDB databáze ve schématu `staging`.
6. Do zdrojových dat jsem přidal časové razítko a údaj o zdroji dat.
7. Snažil jsem se data co nejvíce vyčistit, deduplikovat a celou pipeline zjednodušit.
8. Součástí řešení je i GitHub Action workflow, které má následující fáze:
    - `dbt-check` – provede kompilaci DBT projektu, spustí testy a publikuje [dokumentaci DBT pipeline na S3 bucket](http://book-recommend-dbt-doc.s3-website.eu-north-1.amazonaws.com)
    - `evidence-report` – zkompiluje report a nahraje výsledek na [S3 bucket](http://book-recommend.s3-website.eu-north-1.amazonaws.com)

## Jak projekt zprovoznit (testováno na Windows)

Vyžaduje: `git`, `python`, `pip`, `nodejs`, `make`

```bash
git clone https://github.com/RadimBaca/book_recommend
cd book_recommend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
make download
make dbt-run
npm --prefix reports install
npm --prefix reports run sources
npm --prefix reports run dev
```

## Vedlejší poznámky k mému řešení

Aktuální nasazení bych charakterizoval jako *development*. Produkční nasazení by mohlo běžet plně v cloudu – DBT, DuckDB i Evidence nabízejí čistě cloudové řešení. Produkční nasazení mého řešení je pak už jen otázkou správného nastavení `.env`.

Používám jednotnou konvenci pojmenování – jednotlivé modely a jejich atributy používají jednotné číslování. Atributy mají camelCase zápis, tabulky používají snake_case.

## Výhody použití DBT, SQL a GITu

1. Dokumentace celé pipeline v DBT
2. Verzování a do budoucna transparentní rozšiřování projektu pomocí GITu. Trval bych na tom, aby se dodatečné změny vždy nejprve implementovaly ve vlastní větvi.
3. Testovatelnost celé pipeline (od začátku do konce) v DBT
4. Grafická data lineage, která usnadňuje pochopení celého řešení v DBT. Data pipeline je jasně rozdělena do menších částí (modelů), které na sebe navazují.
5. Deklarativnost SQL zpřehledňuje celé řešení. SQL je klasický nástroj pro práci s daty s jasnými vstupy a výstupy.

# Bonus: Výhody zaměstnání Radima Bači

Můžete se chlubit, že máte ve svých řadách docenta, který s daty pracuje už dvacet let. Může posloužit ke zvýšení prestiže a jako záruka vyšší kvality.
