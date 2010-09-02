<%
/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%
UserThreadLocalServiceUtil.markUserThreadAsRead(user.getUserId(), mbThreadId);
%>

<portlet:renderURL var="backURL" windowState="<%= WindowState.NORMAL.toString() %>" />

<liferay-ui:header
	backLabel='<%= "&laquo; " + LanguageUtil.get(pageContext, "back-to-messages") %>'
	backURL="<%= backURL.toString() %>"
	title="<%= HtmlUtil.escape(PrivateMessagingUtil.getThreadSubject(mbThreadId)) %>"
/>

<aui:layout cssClass="controls">
	<liferay-portlet:actionURL name="markMessagesAsUnread" var="markAsUnreadURL">
		<portlet:param name="mbThreadIds" value="<%= String.valueOf(mbThreadId) %>" />
	</liferay-portlet:actionURL>

	<aui:button name="markAsUnread" onClick="<%= markAsUnreadURL %>" value="mark-as-unread" />

	<liferay-portlet:actionURL name="deleteMessages" var="deleteMessageURL">
		<portlet:param name="mbThreadIds" value="<%= String.valueOf(mbThreadId) %>" />
	</liferay-portlet:actionURL>

	<aui:button name="deleteMessage" onClick="<%= deleteMessageURL %>" value="delete" />
</aui:layout>

<aui:layout cssClass="thread-info">
	Between

	<%
	List<User> users = PrivateMessagingUtil.getThreadUsers(user.getUserId(), mbThreadId, true);

	for (int i = 0; i < users.size(); i++) {
		User tempUser = users.get(i);
		%>

			<liferay-portlet:actionURL var="publicPagesURL" portletName="<%= PortletKeys.MY_PLACES %>">
				<portlet:param name="struts_action" value="/my_places/view" />
				<portlet:param name="groupId" value="<%= String.valueOf(tempUser.getGroup().getGroupId()) %>" />
				<portlet:param name="privateLayout" value="<%= Boolean.FALSE.toString() %>" />
			</liferay-portlet:actionURL>

			<a class="profile-link" href="<%= publicPagesURL %>"><%= tempUser.getFullName() %></a>

			<c:if test="<%= i != (users.size() - 1) %>">
				,
			</c:if>

		<%
	}
	%>

	<liferay-portlet:actionURL var="selfPublicPagesURL" portletName="<%= PortletKeys.MY_PLACES %>">
		<portlet:param name="struts_action" value="/my_places/view" />
		<portlet:param name="groupId" value="<%= String.valueOf(user.getGroup().getGroupId()) %>" />
		<portlet:param name="privateLayout" value="<%= Boolean.FALSE.toString() %>" />
	</liferay-portlet:actionURL>

	and <a class="profile-link" href="<%= selfPublicPagesURL %>"><liferay-ui:message key="you" /></a>

</aui:layout>

<liferay-ui:search-container delta="25" emptyResultsMessage="no-messages-found">
	<liferay-ui:search-container-results>

		<%
		results = PrivateMessagingUtil.getThreadMessages(user.getUserId(), mbThreadId, searchContainer.getStart(), searchContainer.getEnd(), true);
		total = PrivateMessagingUtil.getThreadMessagesCount(user.getUserId(), mbThreadId);

		pageContext.setAttribute("results", results);
		pageContext.setAttribute("total", total);
		%>

	</liferay-ui:search-container-results>

	<liferay-ui:search-container-row
		className="com.liferay.portlet.messageboards.model.MBMessage"
		modelVar="mbMessage"
	>

		<liferay-ui:search-container-column-text valign="top">
			<liferay-ui:user-display
				userId="<%= mbMessage.getUserId() %>"
				userName="<%= mbMessage.getUserName() %>"
				displayStyle="<%= 2 %>"
			/>
		</liferay-ui:search-container-column-text>

		<liferay-ui:search-container-column-text valign="top">
			<%
			User tempUser = UserLocalServiceUtil.getUser(mbMessage.getUserId());
			%>

			<aui:layout>
				<liferay-portlet:actionURL var="publicPagesURL" portletName="<%= PortletKeys.MY_PLACES %>">
					<portlet:param name="struts_action" value="/my_places/view" />
					<portlet:param name="groupId" value="<%= String.valueOf(tempUser.getGroup().getGroupId()) %>" />
					<portlet:param name="privateLayout" value="<%= Boolean.FALSE.toString() %>" />
				</liferay-portlet:actionURL>

				<span class="name">
					<a class="profile-link" href="<%= publicPagesURL %>"><%= HtmlUtil.escape(tempUser.getFullName()) %></a>
				</span>

				<span class="date">
					<%= dateFormatDateTime.format(mbMessage.getCreateDate()) %>
				</span>
			</aui:layout>

			<aui:layout cssClass="body">
				<%= HtmlUtil.escape(mbMessage.getBody()) %>
			</aui:layout>
		</liferay-ui:search-container-column-text>
	</liferay-ui:search-container-row>

	<liferay-ui:search-iterator />
</liferay-ui:search-container>

<aui:layout cssClass="message-body-container">
	<liferay-portlet:renderURL var="backToThreadURL" windowState="<%= WindowState.NORMAL.toString() %>"><portlet:param name="mbThreadId" value="<%= String.valueOf(mbThreadId) %>" /></liferay-portlet:renderURL>

	<form method="post" name="<portlet:namespace />fm" onSubmit="<portlet:namespace />sendPrivateMessage(); return false;">
		<aui:input name="redirect" type="hidden" value="<%= backToThreadURL %>" />
		<aui:input name="userId" type="hidden" value="<%= user.getUserId() %>" />
		<aui:input name="mbThreadId" type="hidden" value="<%= mbThreadId %>" />
		<textarea class="message-body" name="<portlet:namespace />body"></textarea>

		<aui:button-row>
			<aui:button name="send" type="submit" value="send" />
		</aui:button-row>
	</form>
</aui:layout>

<aui:layout cssClass="controls">
	<aui:button onClick="<%= backURL %>" value="back-to-messages" />
</aui:layout>

<aui:script>
	function <portlet:namespace />sendPrivateMessage() {
		submitForm(document.<portlet:namespace />fm, '<liferay-portlet:actionURL name="sendMessage" />');
	}
</aui:script>