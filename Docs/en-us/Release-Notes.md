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

# Release Notes

## [application-name] version <!--- Version No. Start---> <!--- Version No. End---> for Microsoft Dynamics 365 Business Central

This document contains the latest information about the release of [application-name] version <!--- Version No. Start---> <!--- Version No. End---> for Microsoft Dynamics 365 Business Central. Compared to the previous version, functionality changes and fixes have been implemented in the scope described further in the document. This release of [application-name] is based on Microsoft Dynamics 365 Business Central [base-application-major-release-version]. The application is designed for Microsoft Dynamics 365 Business Central online and on-premises in the Premium and Essentials versions.

## Compatibility

[application-name] version <!--- Version No. Start---> <!--- Version No. End---> is compatible with Microsoft Dynamics 365 Business Central [last-compatible-version] and higher.  
If a Microsoft Dynamics 365 Business Central version lower than [last-compatible-version] is installed, use the former release of [application-name].

## New and Changed Functionalities

|ID|Description|
|---|---|

<!--- Tasks List End --->

## Bug Fixes

|ID|Description|
|---|---|
<!--- Issues List End --->

## Support

Application errors should be reported to the following address: [service-desk-email]

## See Also

[Documentation]([application-docs-link])
