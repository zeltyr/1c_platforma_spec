﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	УчетнаяПолитика = РегистрыСведений.УчетнаяПолитика.СрезПоследних(МоментВремени());
	Если УчетнаяПолитика.Количество() = 0 Тогда
		
		Отказ = Истина;
		
	Иначе
		
		МетодСписания = УчетнаяПолитика[0].МетодСписания;
		Если НЕ ЗначениеЗаполнено(МетодСписания) Тогда
			Отказ = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Если Отказ Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не задана учетная политика!";
		Сообщение.Сообщить();
		Возврат;
		
	КонецЕсли;
	
	//Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.ПартииНоменклатуры.Записывать = Истина;
	Движения.Управленческий.Записывать = Истина;
	
	Движения.ОстаткиНоменклатуры.Записать();
	Движения.ПартииНоменклатуры.Записать();
	Движения.Управленческий.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ПартииНоменклатуры");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	Блокировка.Заблокировать();	
	
	// для контроля остатков используем регистр "Остатки" и новую методику
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Дата КАК Дата,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Склад КАК Склад,
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	|	РасходнаяНакладнаяСписокНоменклатуры.Сумма КАК Сумма
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|	И РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = &ВидНоменклатуры
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Дата,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Склад,
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
	|	РасходнаяНакладнаяСписокНоменклатуры.Сумма
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Дата КАК Дата,
	|	ВТ_ДанныеДок.Склад КАК Склад,
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ПартииНоменклатурыОстатки.Партия КАК Партия,
	|	ЕСТЬNULL(ПартииНоменклатурыОстатки.КоличествоОстаток, 0) КАК КоличествоПартии,
	|	ЕСТЬNULL(ПартииНоменклатурыОстатки.СуммаОстаток, 0) КАК СуммаПартии,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПартииНоменклатуры.Остатки(
	|				&МоментВремени,
	|				Номенклатура В
	|					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК ПартииНоменклатурыОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = ПартииНоменклатурыОстатки.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПартииНоменклатурыОстатки.Партия.МоментВремени УБЫВ
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	СУММА(КоличествоПартии)
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("ВидНоменклатуры", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Если МетодСписания = Перечисления.УчетнаяПолитика.ФИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ".МоментВремени УБЫВ", ".МоментВремени");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		Движение = Движения.ОстаткиНоменклатуры.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Склад = Склад;
		Движение.Количество = ВыборкаНоменклатура.Количество;
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоПартии;
		Если НеХватает > 0 Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Не хвататет товара: " + ВыборкаНоменклатура.НоменклатураПредставление + " по партиям в количестве: " + НеХватает;
			Сообщение.Сообщить();
		КонецЕсли;
		
		Если Отказ Тогда 
			Продолжить;
		КонецЕсли;
		
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		
		КоличествоСписать = ВыборкаНоменклатура.Количество;
		
		Пока КоличествоСписать > 0 И ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			КолПоПартии = МИН(КоличествоСписать, ВыборкаДетальныеЗаписи.КоличествоПартии);
			Себестоимость = ?(КолПоПартии = ВыборкаДетальныеЗаписи.КоличествоПартии, 
				ВыборкаДетальныеЗаписи.СуммаПартии, 
				КолПоПартии * ВыборкаДетальныеЗаписи.СуммаПартии / ВыборкаДетальныеЗаписи.КоличествоПартии);
			
			Движение = Движения.ПартииНоменклатуры.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Партия = ВыборкаДетальныеЗаписи.Партия;
			Движение.Количество = КолПоПартии;
			Движение.Сумма = Себестоимость;
			
			КоличествоСписать = КоличествоСписать - КолПоПартии;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Движения.ОстаткиНоменклатуры.БлокироватьДляИзменения = Истина;
	Движения.ОстаткиНоменклатуры.Записать();
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиНоменклатурыОстатки.Номенклатура КАК Номенклатура,
	|	ОстаткиНоменклатурыОстатки.Склад КАК Склад,
	|	-ОстаткиНоменклатурыОстатки.КоличествоОстаток КАК КоличествоОстаток,
	|	ОстаткиНоменклатурыОстатки.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ОстаткиНоменклатурыОстатки.Склад.Представление КАК СкладПредставление
	|ИЗ
	|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(
	|			&Граница,
	|			(Номенклатура, Склад) В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|					ВТ_ДанныеДок.Склад КАК Склад
	|				ИЗ
	|					ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК ОстаткиНоменклатурыОстатки
	|ГДЕ
	|	ОстаткиНоменклатурыОстатки.КоличествоОстаток < 0";
	Запрос.УстановитьПараметр("Граница", Новый Граница(МоментВремени(),ВидГраницы.Включая));
	
	Рез = Запрос.Выполнить();
	Выборка = Рез.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не хватает товара: " + Выборка.НоменклатураПредставление + " по складу: " + Выборка.СкладПредставление + " в количестве: " + Выборка.КоличествоОстаток;
		Сообщение.Сообщить();
		
	КонецЦикла;
	
	#Область БухУчет
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрБухгалтерии.Управленческий");
	ЭлементБлокировки.УстановитьЗначение("Счет", ПланыСчетов.Управленческий.Товары);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура, "Номенклатура");
	Блокировка.Заблокировать();	
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВТ_ДанныеДок.Дата КАК Дата,
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0) КАК КоличествоСрок,
	|	ЕСТЬNULL(УправленческийОстатки.СуммаОстаток, 0) КАК СуммаСрок,
	|	УправленческийОстатки.Субконто2 КАК СрокГодности,
	|	ВТ_ДанныеДок.Сумма КАК Сумма
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = ЗНАЧЕНИЕ(ПланСчетов.Управленческий.Товары),
	|				&МасСубконто,
	|				Субконто1 В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
	|
	|УПОРЯДОЧИТЬ ПО
	|	СрокГодности
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	СУММА(КоличествоСрок),
	|	СУММА(СуммаСрок),
	|	МАКСИМУМ(Сумма)
	|ПО
	|	Номенклатура";
	МасСубконто = Новый Массив;
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.СрокГодности);
	Запрос.УстановитьПараметр("МасСубконто", МасСубконто);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Сумма = 0;
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоСрок;
		Если НеХватает > 0 Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Не хватает товара (бух. учет): " + ВыборкаНоменклатура.НоменклатураПредставление + " в количестве: " + НеХватает;
			Сообщение.Сообщить();
		КонецЕсли;
		
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;
		
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		
		КоличествоСписать =  ВыборкаНоменклатура.Количество;
		КоличествоПартийИтого = ВыборкаНоменклатура.КоличествоСрок;
		СуммаСписано = 0;
		
		Пока КоличествоСписать > 0 И ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			КолПоСроку = МИН(ВыборкаДетальныеЗаписи.КоличествоСрок, КоличествоСписать);
			
			Себестоимость = ?(КоличествоПартийИтого = КолПоСроку, 
				ВыборкаНоменклатура.СуммаСрок - СуммаСписано,
				КолПоСроку * ВыборкаНоменклатура.СуммаСрок / ВыборкаНоменклатура.КоличествоСрок);
				
			КоличествоСписать = КоличествоСписать - КолПоСроку;
			
			Движение = Движения.Управленческий.Добавить();
			Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
			Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
			Движение.Период = Дата;
			Движение.Сумма = Себестоимость;
			Движение.КоличествоКт = КолПоСроку;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.СрокГодности] = ВыборкаДетальныеЗаписи.СрокГодности;
			
			КоличествоПартийИтого = КоличествоПартийИтого - Движение.КоличествоКт; 
			СуммаСписано = СуммаСписано + Движение.Сумма;
			
		КонецЦикла;
		
		Сумма = Сумма +  ВыборкаНоменклатура.Сумма;
			
		
	КонецЦикла;
	
	Движение = Движения.Управленческий.Добавить();
	Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
	Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
	Движение.Период = Дата;
	Движение.Сумма = Сумма;
	
	#КонецОбласти //БухУчет
	
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры
