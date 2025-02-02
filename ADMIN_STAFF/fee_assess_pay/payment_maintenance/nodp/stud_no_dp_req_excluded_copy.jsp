<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PageAction(strAction){
	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT ","stud_no_dp_req_excluded_copy.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"stud_no_dp_req_excluded_copy.jsp");

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


//end of security code.
int iSearchResult = 0;
FAPmtMaintenance faPmt = new FAPmtMaintenance();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if( !faPmt.copyExcludedFromDP(dbOP, request))	
		strErrMsg = faPmt.getErrMsg();
}


if(WI.fillTextValue("sy_from").length() > 0){
	vRetResult = faPmt.operateOnExcludeDP(dbOP, request, 3);	
	if(vRetResult == null)
		strErrMsg = faPmt.getErrMsg();
	else
		iSearchResult = faPmt.getSearchCount();			
}

%>
<form name="form_" action="./stud_no_dp_req_excluded_copy.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
        COPY LIST OF STUDENT EXCLUDED FROM DOWNPAYMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"> &nbsp; &nbsp; &nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">School Year/Term</td>
      <td width="81%" height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <select name="semester">
        	 <option value="">ALL</option>	
<%
strTemp = WI.fillTextValue("semester");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="1" <%=strErrMsg%>>1st</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="2" <%=strErrMsg%>>2nd</option>

<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="3" <%=strErrMsg%>>3rd</option>

<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="0" <%=strErrMsg%>>Summer</option>
        </select>
        &nbsp; &nbsp; &nbsp;
        <input name="image" type="image" src="../../../images/form_proceed.gif" onClick="ReloadPage()" width="81" height="21" border="0"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	
   <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">Copy to School Year/Term</td>
      <td width="81%" height="25">
        <%
strTemp = WI.fillTextValue("copy_sy_from");
%>
        <input name="copy_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","copy_sy_from","copy_sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("copy_sy_to");
%>
        <input name="copy_sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <select name="copy_semester">
        	 <option value="">ALL</option>	
<%
strTemp = WI.fillTextValue("copy_semester");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="1" <%=strErrMsg%>>1st</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="2" <%=strErrMsg%>>2nd</option>

<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="3" <%=strErrMsg%>>3rd</option>

<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="0" <%=strErrMsg%>>Summer</option>
        </select>
        </td>
    </tr>
    <tr><td colspan="3">&nbsp;</td></tr>
	<tr><td colspan="3" height="20" align="center"><strong>LIST OF STUDENT EXCLUDED FROM DOWNPAYMENT FOR SY <%=WI.fillTextValue("sy_from") + "-" +WI.fillTextValue("sy_to")%>
   	<%
		if(WI.fillTextValue("semester").length() > 0)
			strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
		else
			strTemp = "";
		%><%=strTemp%></strong>
   </td>  
	</tr>
</table>

<table  bgcolor="#FFFFFF" class="thinborder" width="100%" border="0" cellspacing="0" cellpadding="0">
	
   <tr> 
			<td class="thinborderBOTTOMLEFT" colspan="2">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(faPmt.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("print_page").equals("1")){
					iPageCount = iSearchResult/faPmt.defSearchSize;		
					if(iSearchResult % faPmt.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+faPmt.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
   <tr>
   	<td width="13%" height="20" class="thinborder"><strong>ID NUMBER</strong></td>
      <td width="33%" class="thinborder"><strong>STUDENT NAME</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>SELECT ALL<br></strong>
         <input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
   </tr>
   <%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=5, iCount++){%>
   <tr>
   	<td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
      <td height="18" class="thinborder"><%=strTemp%></td>
      
      <td class="thinborder" align="center">
         <input  type="checkbox" value="<%=(String)vRetResult.elementAt(i)%>" name="save_<%=iCount%>">
      </td>
   </tr>
   <%}%>
   
   <input type="hidden" name="item_count" value="<%=iCount%>" />
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center"><a href="javascript:PageAction('1')"><img src="../../../images/copy.gif" border="0"></a>
   	<font size="1">Click to copy entry</font>
   </td></tr>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
