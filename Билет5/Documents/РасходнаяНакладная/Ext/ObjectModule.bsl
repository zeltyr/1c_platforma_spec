﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ВзаиморасчетыСКонтрагентами.Записывать = Истина;
	Движения.ВзаиморасчетыСКонтрагентами.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВзаиморасчетыСКонтрагентамиОстатки.Проект КАК Проект,
		|	ВзаиморасчетыСКонтрагентамиОстатки.СуммаОстаток КАК СуммаОстаток,
		|	ЕСТЬNULL(КурсыВалютСрезПоследних.Курс, 0) КАК Курс
		|ИЗ
		|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.Остатки(
		|			&МоментВремени,
		|			Контрагент = &Контрагент
		|				И Проект = ЗНАЧЕНИЕ(Справочник.Проекты.ПустаяСсылка)) КАК ВзаиморасчетыСКонтрагентамиОстатки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(&МоментВремени, Валюта = &Валюта) КАК КурсыВалютСрезПоследних
		|		ПО ИСТИНА";
	
	Запрос.УстановитьПараметр("Валюта", Проект.Валюта);
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		
		Курс = ?(Выборка.Курс = 0, 1, Выборка.Курс);
		СуммаАванса = Окр(Выборка.СуммаОстаток / Курс, 2);
		
		СписатьПоАвансу = МИН(СуммаПоДокументу, СуммаАванса);
		СписатьПоАвансуРуб = СписатьПоАвансу * Курс;
		
		Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = ПредопределенноеЗначение("Справочник.Проекты.ПустаяСсылка");
		Движение.Сумма = СписатьПоАвансуРуб;
		
		Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = Проект;
		Движение.Сумма = СписатьПоАвансу;
		
	КонецЕсли;	

	Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Проект = Проект;
	Движение.Сумма = СуммаПоДокументу;
	
	ОбработкаПроведенияБУХ(Отказ, Режим);
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры

Процедура ОбработкаПроведенияБУХ(Отказ, Режим)
	
	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрБухгалтерии.Управленческий");
	ЭлементБлокировки.УстановитьЗначение("Счет", ПланыСчетов.Управленческий.Товары);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура, "Номенклатура");
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.ИнвентарныйНомер, "ИнвентарныйНомер");
	Блокировка.Заблокировать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	РасходнаяНакладнаяСписокНоменклатуры.ИнвентарныйНомер КАК ИнвентарныйНомер,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.ИнвентарныйНомер,
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура,
	|	ИнвентарныйНомер
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.ИнвентарныйНомер КАК ИнвентарныйНомер,
	|	ВТ_ДанныеДок.Сумма КАК Сумма,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
	|	СУММА(ЕСТЬNULL(УправленческийОстаткиСебестоимость.КоличествоОстаток, 0)) КАК КоличествоИнвНомеров,
	|	СУММА(ЕСТЬNULL(УправленческийОстаткиСебестоимость.СуммаОстаток, 0)) КАК СуммаОстаток
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = &СчетТовары,
	|				&НоменклатураИнвНомер,
	|				(Субконто1, Субконто2) В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|						ВТ_ДанныеДок.ИнвентарныйНомер КАК ИнвентарныйНомер
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
	|			И ВТ_ДанныеДок.ИнвентарныйНомер = УправленческийОстатки.Субконто2
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = &СчетТовары,
	|				&НоменклатураИнвНомер,
	|				Субконто1 В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстаткиСебестоимость
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстаткиСебестоимость.Субконто1
	|ГДЕ
	|	УправленческийОстатки.КоличествоОстаток <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ДанныеДок.Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.Представление,
	|	ВТ_ДанныеДок.ИнвентарныйНомер,
	|	ВТ_ДанныеДок.Сумма,
	|	ВТ_ДанныеДок.Количество,
	|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0)";
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	МасСубконто = Новый массив;
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.ИнвентарныйНомер);
	Запрос.УстановитьПараметр("НоменклатураИнвНомер", МасСубконто);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("СчетТовары", ПланыСчетов.Управленческий.Товары);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НеХватает = ВыборкаДетальныеЗаписи.Количество - ВыборкаДетальныеЗаписи.КоличествоОстаток;
		Если НеХватает > 0 Тогда
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Товара: %1 с заданным инв. номером: %2 не хватает в количестве: %3", ВыборкаДетальныеЗаписи.НоменклатураПредставление, ВыборкаДетальныеЗаписи.ИнвентарныйНомер, НеХватает);
			Сообщение.Сообщить();
		КонецЕсли;
		
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;
		
		Себестоимость = ?(ВыборкаДетальныеЗаписи.Количество = ВыборкаДетальныеЗаписи.КоличествоИнвНомеров, 
			ВыборкаДетальныеЗаписи.СуммаОстаток,
			ВыборкаДетальныеЗаписи.Количество * ВыборкаДетальныеЗаписи.СуммаОстаток / ВыборкаДетальныеЗаписи.КоличествоИнвНомеров);
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
		Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
		Движение.Период = Дата;
		Движение.Сумма = Себестоимость;
		Движение.КоличествоКт = ВыборкаДетальныеЗаписи.Количество;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.ИнвентарныйНомер] = ВыборкаДетальныеЗаписи.ИнвентарныйНомер;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.ИнвентарныйНомер] = ВыборкаДетальныеЗаписи.ИнвентарныйНомер;
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
		Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
		Движение.Период = Дата;
		Движение.Сумма = ВыборкаДетальныеЗаписи.Сумма;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.ИнвентарныйНомер] = ВыборкаДетальныеЗаписи.ИнвентарныйНомер;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если СписокНоменклатуры.Количество() > 0 Тогда
		СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	КонецЕсли;
КонецПроцедуры
