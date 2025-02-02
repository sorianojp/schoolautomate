<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.request_index.value = "";
		document.form_.delete_remark.value = "";
		document.form_.release_remark.value = "";
		document.form_.submit();
	}
	
	function PrintPage(strInfoIndex){
		document.form_.print_page.value = "1";		
		document.form_.submit();
	}
	
	function DeleteDocument(strInfoIndex){
		document.form_.delete_remark.value = prompt("Remarks to Delete");		
		document.form_.request_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
	function ReleaseDocument(strInfoIndex){
		document.form_.release_remark.value = prompt("Remarks to Release");		
		document.form_.request_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.page_action.value = "2";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./request_due_made_print.jsp"/>
	<%return;}
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","request_due_made.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"request_due_made.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	int iSearchResult = 0;
	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = new Vector();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(strTemp.equals("1")){
			if(!docReq.deleteRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully deleted.";
		}else{
			if(!docReq.releaseRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully released.";
		}
			
	}
	
	strTemp = WI.getStrValue(WI.fillTextValue("show_in"),"1");
	vRetResult = docReq.getRequestDueAndMade(dbOP, request, Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = docReq.getErrMsg();	

%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="request_due_made.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        DOCUMENT REQUEST TRACKING ::::</strong></font></td>
    </tr>
</table>
<jsp:include page="./tabs.jsp?pgIndex=0"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>			
		    <td height="15" colspan="2">
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("show_in"), "1");
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_in" value="1" <%=strTemp%> onChange="javascript:ReloadPage();">Show request due for today&nbsp;&nbsp;
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_in" value="2" <%=strTemp%> onChange="javascript:ReloadPage();">Show request made today</td>
		</tr>
		<tr><td height="10" colspan="2"></td></tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td></tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<%
				strTemp = "REQUEST";
				if(WI.fillTextValue("show_in").equals("1"))
					strTemp = "DUE REQUEST";
			%>
		  	<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>::: TODAY'S <%=strTemp%> ::: </strong></div></td>
		</tr>
		
		<tr>
			<td height="23" class="thinborder" width="5%"><strong>COUNT</strong></td>
			<td class="thinborder" width="12%"><strong>DATE REQUESTED</strong></td>
			<td class="thinborder" width="25%"><strong>STUDENT NAME</strong></td>
			<td class="thinborder" width="15%"><strong>DOCUMENT NAME</strong></td>
			<td class="thinborder" width="12%"><strong>RELEASE DATE</strong></td>
			<td class="thinborder" ><strong>REQUIREMENTS</strong></td>
			<td class="thinborder" align="center" width="12%"><strong>OPTION</strong></td>
		</tr>
	<%	int iCount = 1;
		String strReleased = null;
		String strDocRequirement = null;
		Vector vReqList = new Vector();
		
		for(int i = 0; i < vRetResult.size(); i += 8){
			strReleased = (String)vRetResult.elementAt(i+7);
			strDocRequirement = "";
			vReqList = (Vector)vRetResult.elementAt(i+5);
				if(vReqList.size() > 0) {
					for(int x = 0; x < vReqList.size(); x++){
						if((String)vReqList.elementAt(x) != null){
							if(strDocRequirement.length() == 0)
								strDocRequirement = (String)vReqList.elementAt(x)+";";
							else
								strDocRequirement += "<br>"+(String)vReqList.elementAt(x)+";";						
						}
						
					}
				}
			
		
		%>
		<tr>
			<td height="23" class="thinborder"><%=iCount++%>.</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
			<td class="thinborder" align="center">
				<%if(strReleased.equals("1")){%>
					RELEASED
				<%}else{%>
				<a href="javascript:DeleteDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
				&nbsp;
				<a href="javascript:ReleaseDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/release-02-55x18.gif" border="0"></a>
				<%}%>
			</td>
		</tr>
		<%}%>
	</table>
<%}%>	

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="release_remark" value="<%=WI.fillTextValue("release_remark")%>"/>
	<input type="hidden" name="delete_remark" value="<%=WI.fillTextValue("delete_remark")%>"/>
	<input type="hidden" name="request_index" value="<%=WI.fillTextValue("request_index")%>"/>
	<input type="hidden" name="page_action" value="" />
	<input type="hidden" name="print_page" />
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>