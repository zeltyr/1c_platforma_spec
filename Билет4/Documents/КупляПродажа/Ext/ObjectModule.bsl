﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрБухгалтерии.Управленческий");
	ЭлементБлокировки.УстановитьЗначение("Счет",  ПланыСчетов.Управленческий.Товары);
	ЭлементБлокировки.УстановитьЗначение("Организация",  ОрганизацияПоставщик);
	ЭлементБлокировки.УстановитьЗначение(ПланыВидовХарактеристик.ВидыСубконто.Склад, СкладПоставщик);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура, "Номенклатура");
	Блокировка.Заблокировать();
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КупляПродажаСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(КупляПродажаСписокНоменклатуры.Количество) КАК Количество,
	|	СУММА(КупляПродажаСписокНоменклатуры.Сумма) КАК Сумма,
	|	&Склад КАК Склад,
	|	&ОрганизацияПоставщик КАК ОрганизацияПоставщик
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.КупляПродажа.СписокНоменклатуры КАК КупляПродажаСписокНоменклатуры
	|
	|СГРУППИРОВАТЬ ПО
	|	КупляПродажаСписокНоменклатуры.Номенклатура
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ОрганизацияПоставщик,
	|	Склад,
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ВТ_ДанныеДок.Сумма КАК Сумма,
	|	ВТ_ДанныеДок.Склад КАК Склад,
	|	ВТ_ДанныеДок.ОрганизацияПоставщик КАК ОрганизацияПоставщик,
	|	УправленческийОстатки.Субконто3 КАК Партия,
	|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0) КАК КоличествоПоПартии,
	|	ЕСТЬNULL(УправленческийОстатки.СуммаОстаток, 0) КАК СуммаПоПартии
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = &СчетТовары,
	|				&МасСубконто,
	|				(Организация, Субконто1, Субконто2) В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.ОрганизацияПоставщик КАК ОрганизацияПоставщик,
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|						ВТ_ДанныеДок.Склад КАК Склад
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстатки
	|		ПО ВТ_ДанныеДок.ОрганизацияПоставщик = УправленческийОстатки.Организация
	|			И ВТ_ДанныеДок.Склад = УправленческийОстатки.Субконто2
	|			И ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
	|
	|УПОРЯДОЧИТЬ ПО
	|	УправленческийОстатки.Субконто3.МоментВремени
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	Сумма(КоличествоПоПартии),
	|	МАКСИМУМ(Сумма)
	|ПО
	|	Номенклатура";
	
	МасСубконто = Новый Массив;
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склад);
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партия);
	Запрос.УстановитьПараметр("МасСубконто", МасСубконто);
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("ОрганизацияПоставщик", ОрганизацияПоставщик);
	Запрос.УстановитьПараметр("Склад", СкладПоставщик);
	Запрос.УстановитьПараметр("СчетТовары", ПланыСчетов.Управленческий.Товары);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоПоПартии;
		Если НеХватает > 0 Тогда
			
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хвататет товара: %1 на складе поставщика в количестве: %2", ВыборкаНоменклатура.НоменклатураПредставление, НеХватает);
			Сообщение.Сообщить();
			
		КонецЕсли;
		
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;
		
		КоличествоСписать = ВыборкаНоменклатура.Количество;
	
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
			
		
		Пока КоличествоСписать > 0 И ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			СписатьПоПартии = МИН(КоличествоСписать, ВыборкаДетальныеЗаписи.КоличествоПоПартии);
			Если СписатьПоПартии = 0 Тогда
				Продолжить;
			КонецЕсли;
			КоличествоСписать = КоличествоСписать - СписатьПоПартии;
			
			Себестоимость = ?(СписатьПоПартии = ВыборкаДетальныеЗаписи.КоличествоПоПартии,
				ВыборкаДетальныеЗаписи.СуммаПоПартии,
				СписатьПоПартии * ВыборкаДетальныеЗаписи.СуммаПоПартии / ВыборкаДетальныеЗаписи.КоличествоПоПартии);
			
			Движение = Движения.Управленческий.Добавить();
			Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
			Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
			Движение.Период = Дата;
			Движение.Организация = ОрганизацияПоставщик;
			Движение.КоличествоКт = ВыборкаДетальныеЗаписи.Количество;
			Движение.Сумма = Себестоимость;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склад] = СкладПоставщик;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Партия] = ВыборкаДетальныеЗаписи.Партия;
			
		КонецЦикла;
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.Товары;
		Движение.СчетКт = ПланыСчетов.Управленческий.Поставщики;
		Движение.Период = Дата;
		Движение.Организация = ОрганизацияПокупатель;
		Движение.КоличествоДт = ВыборкаНоменклатура.Количество;
		Движение.Сумма = ВыборкаНоменклатура.Сумма;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаНоменклатура.Номенклатура;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Склад] = СкладПокупатель;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Партия] = Ссылка;
		
	КонецЦикла;
	Движение = Движения.Управленческий.Добавить();
	Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
	Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
	Движение.Период = Дата;
	Движение.Организация = ОрганизацияПоставщик;
	Движение.Сумма = СуммаДокумента;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Организация] = ОрганизацияПокупатель;

	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	СуммаДокумента = СписокНоменклатуры.Итог("Сумма");
КонецПроцедуры
