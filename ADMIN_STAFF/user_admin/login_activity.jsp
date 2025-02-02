<%@ page language="java" import="utility.*,java.util.Vector,enrollment.LoginActivity" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	document.form_.print_pg.value="";
	document.form_.reload_page.value="0";
	document.form_.submit();
}	
function PrintPg()
{
	document.form_.print_pg.value="1";
	document.form_.reload_page.value="";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.print_pg.value="";
	document.form_.reload_page.value="1";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
if( WI.fillTextValue("print_pg").compareTo("1") ==0)
{ %>
	<jsp:forward page="./login_activity_print.jsp" />
<%}
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null; String strTemp3 = null;
	Vector vRetResult = new Vector();
	int iSearchResult =0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Login activity","login_activity.jsp");
	}
	catch(Exception exp)
	{
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
														"System Administration",
														"USER MANAGEMENT",request.getRemoteAddr(), 
														"login_activity.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
LoginActivity loginActivity = new LoginActivity();
if(WI.fillTextValue("reload_page").compareTo("1") != 0) {
	vRetResult = loginActivity.getLoginActivitySummary(dbOP, request);
	if(vRetResult == null)
		strErrMsg = loginActivity.getErrMsg();
	else {
		iSearchResult = loginActivity.getSearchCount();
	}
}

%>

<form name="form_" action="./login_activity.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LOGIN DETAIL INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
	</table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="20%" height="24">Employee ID </td>
      <td width="77%" height="24"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (to show only one Employee record)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Date Range</td>
      <td height="25"> From 
        <input name="from_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("from_date")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="to_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("to_date")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="25"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"><select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">View login whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");
			 
			 for(int i=++j; i<26; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><br> 
	  <a href="javascript:goToNextSearchPage();"><img src="../../images/form_proceed.gif" border="0"></a>
        <font color="#0000FF"><strong>NOTE :</strong> If date range is not selected, 
        result shown is for today's date.</font></td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" ></a><font size="1">click 
          to print listing/report</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">LOGIN 
          INFORMATION FOR DATE (<%=WI.getStrValue(WI.fillTextValue("from_date"),WI.getTodaysDate(1))%>
		  <%=WI.getStrValue(WI.fillTextValue("to_date")," to ","","")%>)</div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25"><b> TOTAL RESULT : <%=iSearchResult%> - Showing(<%=loginActivity.getDisplayRange()%>)</b></td>
      <td width="34%"> 
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/loginActivity.defSearchSize;
		if(iSearchResult % loginActivity.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page: 
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="25"><div align="center"><font size="1"><strong>DATE(MM/DD/YYYY)</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>LOGIN ID</strong></font></div></td>
      <td width="26%"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>TIME-IN</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>TIME-OUT</strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>LOGIN IP</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>LOGIN DURATION</strong></font></div></td>
<!--      <td width="9%"><div align="center"><strong><font size="1">VIEW WORK DETAIL</font></strong></div></td>
-->    </tr>
    <%for(int i = 0; i< vRetResult.size(); i +=7){%>
    <tr> 
      <td height="25" align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i))%></font></td>
      <td align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+1))%></font></td>
      <td align="center"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i+2))%></font></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+4), "&nbsp;")%></font></div></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+6),"Not loggedout")%></font></td>
<!--      <td><div align="center"><img src="../../images/view.gif" border="0" ></div></td>
-->    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" ></a><font size="1">click 
        to print listing/report</font></td>
    </tr>
  </table>
 <%}//only if vRetResult is not null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_pg">
<input type="hidden" name="reload_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>