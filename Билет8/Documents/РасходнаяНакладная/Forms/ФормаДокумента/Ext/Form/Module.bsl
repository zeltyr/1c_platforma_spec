﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	
	ПараметрыОпций = Новый Структура;
	ПараметрыОпций.Вставить("Период", 
		?(ЗначениеЗаполнено(Объект.Дата), Объект.Дата, ТекущаяДатаСеанса()));
	ПараметрыОпций.Вставить("Менеджер", ПараметрыСеанса.ТекущийПользователь);
	
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
	
КонецПроцедуры
