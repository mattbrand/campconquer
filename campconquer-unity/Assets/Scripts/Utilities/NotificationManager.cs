/*
using UnityEngine;
using System;
using Area730.Notifications;

/// <summary>
/// Handles Scheduling Location Notifications.
/// </summary>
public class NotificationManager : MonoBehaviour 
{
	#region Public Vars
	public static NotificationManager Instance = null;
	#endregion

	#region Localization Strings
	[LocalizationKey("OutOfStockBody")]
	string STOCK_BODY = "{x} ran out!";
	[LocalizationKey("OutOfStockAction")]
	string STOCK_ACTION = "Restock {x}";
	[LocalizationKey("ExpenseBody")]
	string EXPENSE_BODY = "Time to pay your expenses!";
	[LocalizationKey("ExpenseAction")]
	string EXPENSE_ACTION = "View your expense report";
	[LocalizationKey("RobberyBody")]
	string ROBBERY_BODY = "Your restaurant has been robbed!";
	[LocalizationKey("TickerText")]
	string TICKER_TEXT = "Remember to check out your restaurant!";
	[LocalizationKey("EventAction")]
	string EVENT_ACTION = "Open restaurant";
	[LocalizationKey("EventBodyCustomer")]
	string EVENT_BODY_CUSTOMER = "A customer has a special request!";
	[LocalizationKey("EventBodyVisitor")]
	string EVENT_BODY_VISITOR = "You have a special visitor!";
	[LocalizationKey("EventBodyFashion")]
	string EVENT_BODY_FASHION = "A customer thinks you're really stylish.";
	#endregion

	#region Unity Methods
	void Awake()
	{
		if(Instance == null)
		{
			Instance = this;
			DontDestroyOnLoad(gameObject);
			#if UNITY_IOS
			UnityEngine.iOS.NotificationServices.RegisterForNotifications(UnityEngine.iOS.NotificationType.Alert);
			#endif
		}
		else
			Destroy(gameObject);
	}
	#endregion

	#region Methods
	public void ScheduleOutOfStock(FoodItem item)
	{
		#if UNITY_IOS
		UnityEngine.iOS.LocalNotification notification = new UnityEngine.iOS.LocalNotification();
		notification.alertAction = Helper.ReplaceValue(STOCK_ACTION,item.Name);
		notification.alertBody = Helper.ReplaceValue(STOCK_BODY,item.Name);
		notification.fireDate = item.ExpiredDate.ToLocalTime();

		UnityEngine.iOS.NotificationServices.ScheduleLocalNotification(notification);
		#elif UNITY_ANDROID
		TimeSpan delay  = item.ExpiredDate.ToLocalTime() - DateTime.Now;

		NotificationBuilder builder = new NotificationBuilder(1, 
			Helper.ReplaceValue(STOCK_BODY,item.Name), Helper.ReplaceValue(STOCK_ACTION,item.Name));
		builder
			.setTicker(TICKER_TEXT)
			.setDefaults(NotificationBuilder.DEFAULT_ALL)
			.setAlertOnlyOnce(true)
			.setDelay(delay)
			.setAutoCancel(true)
			.setGroup(item.Name)
			.setColor("#B30000");

		AndroidNotifications.scheduleNotification(builder.build());
		#endif
	}
	public void ScheduleExpense(DateTime date)
	{
		#if UNITY_IOS
		UnityEngine.iOS.LocalNotification notification = new UnityEngine.iOS.LocalNotification();
		notification.alertAction = EXPENSE_ACTION;
		notification.alertBody = EXPENSE_BODY;
		notification.fireDate = date;

		UnityEngine.iOS.NotificationServices.ScheduleLocalNotification(notification);
		#elif UNITY_ANDROID
		TimeSpan delay  = date - DateTime.Now;

		NotificationBuilder builder = new NotificationBuilder(2,EXPENSE_BODY, EXPENSE_ACTION);
		builder
			.setTicker(TICKER_TEXT)
			.setDefaults(NotificationBuilder.DEFAULT_ALL)
			.setAlertOnlyOnce(true)
			.setDelay(delay)
			.setAutoCancel(true)
			.setGroup("Expenses")
			.setColor("#B30000");

		AndroidNotifications.scheduleNotification(builder.build());
		#endif
	}

	public void ScheduleEvent(RandomEvent evnt)
	{
		string content = GetEventMessage(evnt);
		#if UNITY_IOS
		UnityEngine.iOS.LocalNotification notification = new UnityEngine.iOS.LocalNotification();
		notification.alertAction = EVENT_ACTION;
		notification.alertBody = content;
		notification.fireDate = evnt.OccursAt;

		UnityEngine.iOS.NotificationServices.ScheduleLocalNotification(notification);
		#elif UNITY_ANDROID
		TimeSpan delay  = evnt.OccursAt - DateTime.Now;

		NotificationBuilder builder = new NotificationBuilder(3,content, EVENT_ACTION);
		builder
		.setTicker(TICKER_TEXT)
		.setDefaults(NotificationBuilder.DEFAULT_ALL)
		.setAlertOnlyOnce(true)
		.setDelay(delay)
		.setAutoCancel(true)
		.setGroup(evnt.GetType().ToString())
		.setColor("#B30000");

		AndroidNotifications.scheduleNotification(builder.build());
		#endif
	}
	public void CancelNotifications()
	{
		#if UNITY_IOS
		UnityEngine.iOS.NotificationServices.CancelAllLocalNotifications();
		#elif UNITY_ANDROID
		AndroidNotifications.cancelAll();
		#endif
	}
	string GetEventMessage(RandomEvent evnt)
	{
		Type type = evnt.GetType();
		if(type == typeof(VisitorEvent))
			return EVENT_BODY_VISITOR;
		else if(type == typeof(FashionEvent))
			return EVENT_BODY_FASHION;
		else
			return EVENT_BODY_CUSTOMER;
	}
	#endregion
}
*/