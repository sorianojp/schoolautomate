<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function PreparedToEdit(strIndex) {
	document.form_.info_index.value = strIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
 
function GoToPage3(strSubIndex) {
	var loadPg = "./is_page3.jsp?sub_index="+strSubIndex+
								"&is_main_index="+document.form_.is_main_index.value;
	var win=window.open(loadPg,"page3",'dependent=yes,width=550,height=400,top=35,left=35,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.IncomeStatement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-IncomeStatement-Set up Income Statement","is_page2.jsp");
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
														"Accounting","IncomeStatement",request.getRemoteAddr(), 
														"is_page2.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	
	IncomeStatement incomeState = new IncomeStatement();	
	Vector vRetResult        = null;
	Vector vEditInfo         = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(incomeState.operateOnISSetupSub(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = incomeState.getErrMsg();
		else {
			strErrMsg = "Income Statement set up information updated successfully.";	
			strPreparedToEdit = "0";
		}
	}
	vRetResult = incomeState.operateOnISSetupSub(dbOP, request, 4);
	if(strPreparedToEdit.equals("1"))
		vEditInfo = incomeState.operateOnISSetupSub(dbOP, request, 3);
%>
	

<form name="form_" method="post" action="is_page2.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25" align="center" style="font-weight:bold; color:#FFFFFF">:::: SETUP FOR INCOME STATEMENT - ENTRIES PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Chart of account  Reference : 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("coa_ref");
%>
	  <select name="coa_ref">
		<%=dbOP.loadCombo("COA_INDEX","COMPLETE_CODE, ACCOUNT_NAME"," from AC_COA where account_type = 0 " +
											" and COA_CF = "+ WI.fillTextValue("is_main_index") + 
											" and not exists(select * from AC_SET_IS_SUB where COA_INDEX = COA_HEADER) " +
											" order by ACCOUNT_CODE_INT asc",strTemp, false)%>
      </select>	  </td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="19%">Group Name : </td>
      <td width="77%">
		<%
		if(vEditInfo != null) 
			strTemp = (String)vEditInfo.elementAt(1);
		else	
			strTemp = WI.fillTextValue("group_name");
		%>
	  <input name="group_name" type="text" value="<%=strTemp%>" size="64" maxlength="256" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Group Order : </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("order_no");

int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "0"));	
%>
	  <select name="order_no">
<%for(int i = 1; i < 20; ++i) {
	if(i == iTemp)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
        </select> </td>
    </tr>
    

    <%
if(iAccessLevel ==2){%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%
 			if(iAccessLevel > 1){
			if(strPreparedToEdit.equals("0")) {%>
        <input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
      <%}else{%>
				<%
					if(vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(0);
					else
						strTemp = "0";
				%>
        <input type="submit" name="1" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value=<%=strTemp%>">
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="submit" name="1" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.date_taken.value='';document.form_.license_no.value='';document.form_.remarks.value=''">
			<%}
			}%>			</td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder" align="center"><font color="#FFFFFF"><strong>:: TITLES/NAME TO APPEAR IN INCOME STATEMENT :: </strong></font></td>
    </tr>
    <tr>
      <td width="9%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px; font-weight:bold">Order No </span></td> 
      <td width="30%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Group Name </td>
      <td width="33%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Complete code (name)</td>
      <td width="16%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Edit/Delete</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Update Sub item </td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 5) {%>
    <tr>
			<%
				strTemp =(String)vRetResult.elementAt(i + 2);
			%>		
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
			<%
				strTemp =(String)vRetResult.elementAt(i + 4);
				strTemp = WI.getStrValue(strTemp,"", "(" +(String)vRetResult.elementAt(i + 3) + ")","");
			%>						
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder">
      <%if(iAccessLevel > 1){%>
				<a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');">Edit</a>
      <%}else{%>
	      &nbsp;
      <%}%>
      <%if(iAccessLevel == 2){%>      
				<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
      <%}else{%>
  	    &nbsp;
      <%}%></td>
      <td align="center" class="thinborder"><a href="javascript:GoToPage3('<%=vRetResult.elementAt(i)%>');"><img src="../../../../images/update.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    
    <tr>
      <td height="27" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
	<input type="hidden" name="is_main_index" value="<%=WI.fillTextValue("is_main_index")%>">	
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>