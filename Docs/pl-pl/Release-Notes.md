<!-- Uwagi do wydania, to dokument, który należy dodawać do każdego wydania aplikacji utrzymywanych w jednym repozytorium. Głównym elementem dokumentu są listy zmian funkcjonalnych oraz poprawek dostarczanych w ramach wydania.
Szablon Uwag do wydania, należy zapisać w folderze Scripts/Resources w repozytorium aplikacji. Następnie należy uzupełnić metadane dotyczące aplikacji, czyli wszystkie wystąpienia poniższych elementów zastąpić właściwym opisem.
[application-name] - Oficjalna nazwa aplikacji
[application-docs-link] - Link do dokumentacji aplikacji (np. https://docs.it.integro.pl/pl-pl/mdms/)
[service-desk-email] - adres e-mail kolejki zgłoszeń serwisowych
[base-application-major-release] - opis wersji aplikacji na której bazuje to wydanie (np. 2020 wave 2, 2021 wave 1 itp.)
[last-compatible-version] - opis najniższej wersji, z którą aplikacja jest kompatybilna

Po uzupełnieniu wszystkich metadanych, należy cały dokument sprawdzić i w razie potrzeby skorygować.
Szablon należy traktować jako podstawę do generowania dokumentu Uwagi do wydania. Ponieważ jest on elementem repozytorium aplikacji, w przypadku dodatkowych wymagań można go zmieniać i rozszerzać.

Uwaga, szablon zawiera również tagi w formie komentarzy ( np. Version No., Tasks List End, Issues List End), których nie należy zmieniać. Tagi są wykorzystywane przez pipeline CI. W ich miejsce zostaną automatycznie wpisane np. nr wersji, lista błędów itp. -->

# Uwagi do wydania

## [application-name] wersja <!--- Version No. Start---> <!--- Version No. End---> dla Microsoft Dynamics 365 Business Central

Niniejszy dokument zawiera najnowsze informacje dotyczące wydania aplikacji [application-name] w wersji <!--- Version No. Start---> <!--- Version No. End---> dla Microsoft Dynamics 365 Business Central. W porównaniu z poprzednią wersją, wprowadzono zmiany funkcjonalne oraz poprawki w zakresie przedstawionym w dalszej części dokumentu.
To wydanie [application-name] bazuje na Microsoft Dynamics 365 Business Central [base-application-major-release-version].
Aplikacja jest przeznaczona dla Microsoft Dynamics 365 Business Central online i on-premises w wersjach Premium oraz Essentials.

## Kompatybilność

Aplikacja [application-name] w wersji <!--- Version No. Start---> <!--- Version No. End---> jest kompatybilna z Microsoft Dynamics 365 Business Central  [last-compatible-version] i wyższymi.  
W przypadku gdy zainstalowano Microsoft Dynamics 365 Business Central w wersji niższej niż [last-compatible-version], należy skorzystać ze starszego wydania [application-name].

## Nowe i zmienione funkcjonalności

|ID|Opis|
|---|---|
<!--- Tasks List End --->

## Poprawki błędów

|ID|Opis|
|---|---|
<!--- Issues List End --->

## Wsparcie

Błędy aplikacji należy zgłaszać na adres: [service-desk-email]

## Zobacz też

[Dokumentacja]([application-docs-link])
