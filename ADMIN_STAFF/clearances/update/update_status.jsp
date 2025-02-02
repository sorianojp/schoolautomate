<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script>
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	if(eval(document.form_.type_index.selectedIndex) > 0)
		document.form_.ctype.value=document.form_.type_index[document.form_.type_index.selectedIndex].text;
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
-->
</script>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vStudInfo = null;
	Vector vAuthClr = null;
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vAuthIndex = null;
	boolean bolIsAuth = false;
	
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./update_status_printsig.jsp" />
	<%	return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Update-Update Status","update_status.jsp");
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
														"Clearances","Clearance Update",request.getRemoteAddr(),
														"update_status.jsp");
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

	ClearanceMain clrMain = new ClearanceMain();
	vAuthIndex = clrMain.retreiveAuthClearance(dbOP, request, 1);
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrMain.operateOnClearancePmt(dbOP, request, Integer.parseInt(strTemp)) != null )
			strErrMsg = "Operation successful.";
		else		
			strErrMsg = clrMain.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vStudInfo = clrMain.operateOnClearancePmt(dbOP, request, 3);
		if(vStudInfo == null && strErrMsg == null ) 
			strErrMsg = clrMain.getErrMsg();
	}
	
	vRetResult = clrMain.operateOnClearancePmt(dbOP, request, 4);
	iSearchResult = clrMain.getSearchCount();
	if (strErrMsg == null && WI.fillTextValue("type_index").length()>0)
		strErrMsg = clrMain.getErrMsg();
	
%>

<body bgcolor="#D2AE72">
<form action="update_status.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLEARANCE DUE UPDATE STATUS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  <td colspan="5" height="20"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
  </tr>
  <tr>
  	<td width="5%" height="20">&nbsp;</td>
  	<td width="17%">Clearance Type</td>
  	<td width="20%">
	<select name="type_index" onChange="ReloadPage();">
        <%
			strTemp = WI.fillTextValue("type_index");
	  	vAuthClr = clrMain.retreiveAuthClearance(dbOP, request,2);
	  	if(vAuthClr != null && vAuthClr.size() > 0) {
		  for(int i = 0 ; i< vAuthClr.size(); i +=2){ 
			if( strTemp.compareTo((String)vAuthClr.elementAt(i)) == 0) {%>
        <option value="<%=(String)vAuthClr.elementAt(i)%>" selected><%=(String)vAuthClr.elementAt(i+1)%></option>
        <%}else{%>
        <option value="<%=(String)vAuthClr.elementAt(i)%>"><%=(String)vAuthClr.elementAt(i+1)%></option>
        <%}
			}
		   }%>
    </select></td>
  	<td colspan="2" width="58%">&nbsp;</td>
  </tr>
  <tr>
  <td colspan="5"><hr size="1" noshade></td>
  </tr>
  <tr>
  <td>&nbsp;</td>
  <td>Student ID</td>
  	<%strTemp = WI.fillTextValue("stud_id");%>
  <td><input name="stud_id" type="text" size="16" maxlength="16" class="textbox"
       onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' value="<%=strTemp%>" onKeyUp="AjaxMapName('1');"></td>
  <td colspan="2"><font size="1"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a> click to search student ID</font></td>
  </tr>
  <tr>
  <td height="10">&nbsp;</td>
  <td height="10" colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
  <td height="10">&nbsp;</td>
  </tr>
  <tr>
  <td colspan="2">&nbsp;</td>
  <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td><td>
  </td></tr>
<tr>
<td colspan="4" height="10">&nbsp;</td>
</tr>
  </table>
<%if (vStudInfo !=null && vStudInfo.size()>0 && strPrepareToEdit.compareTo("1") == 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <input type="hidden" name="payable_index" value = "<%=(String)vStudInfo.elementAt(0)%>">
      <td height="25" colspan="4"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="4%">&nbsp;</td>
            <td width="46%" height="25"><font size="1">Name of Student :<strong> <%=WI.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2), (String)vStudInfo.elementAt(3),7)%></strong></font></td>
            <td width="50%"><font size="1">ID Number : <strong><%=(String)vStudInfo.elementAt(4)%></strong></font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td height="25"><font size="1">Course/Major : <strong><%=(String)vStudInfo.elementAt(5)%>&nbsp;<%=WI.getStrValue((String)vStudInfo.elementAt(6),"","","&nbsp;")%></strong></font></td>
            <td><font size="1"> Year Level : <strong><%=WI.getStrValue((String)vStudInfo.elementAt(7),"","","N/A")%></strong></font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td height="15">&nbsp;</td>
            <td height="15">&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td width="11%" height="25">&nbsp;</td>
      <td width="17%" height="25"><font size="1">Amount</font></td>
      <td width="72%" height="25"  colspan="2"><font size="1"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(8),"","","NONE")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1">Quantity</font></td>
      <td  colspan="2" height="25"><font size="1"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(9),"","&nbsp;","NONE")%><%=WI.getStrValue((String)vStudInfo.elementAt(10),"&nbsp;","","&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1">Requirement</font></td>
      <td  colspan="2" height="25"><font size="1"><%=WI.getStrValue((String)vStudInfo.elementAt(11),"","","NONE")%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp; </td>
      <td height="25"> <font size="1">Remarks</font></td>
      <td  colspan="2" height="25"><font size="1"><%=WI.getStrValue((String)vStudInfo.elementAt(12),"","","NONE")%></font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr>
    	<td height="25"></td>
    	<td height="25"></td>
    	<td  colspan="2" height="25"><font size="1">
    		<input type="checkbox" name="isFull" value="1">
        tick if fully complied</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp; </td>
      <td height="25"> Remarks</td>
      <td  colspan="2" height="25"><textarea name="pmt_remark" cols="50" rows="3"><%=WI.getStrValue((String)vStudInfo.elementAt(13),"","","")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Date Cleared</td>
       <%	if(vStudInfo != null && vStudInfo.size() > 0){
				if (vStudInfo.elementAt(14) == null)
					strTemp = "";
				else
					strTemp = (String)vStudInfo.elementAt(14);}
		else{	
			strTemp = WI.fillTextValue("date_clear");}
	%> 
      <td height="25" colspan="2"><input name="date_clear" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_clear');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong> <a href='javascript:PageAction(1,"<%=(String)vStudInfo.elementAt(0)%>");'><img src="../../../images/save.gif" width="48" height="28" border="0"></a></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save entries <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
  </table>
  <%}%>
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr> 
		<td height="25" colspan="8" bgcolor="#B9B292"  class="thinborder">
			<div align="center">LIST OF STUDENTS WITH PENDING STATUS UNDER CLEARANCE: <strong><%=WI.getStrValue(request.getParameter("ctype"))%></strong></div>
		</td>
	</tr>
	<tr>
		<td colspan="8" height="25" class="thinborder">
			<div align="right">
				<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/clrMain.defSearchSize;
		if(iSearchResult % clrMain.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)	{%>Jump
				To page: 
				<select name="jumpto" onChange="ReloadPage();">
					<%
			strTemp = request.getParameter("jumpto");
		
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%	}}	%>
				</select>
				<%} else {%>&nbsp;<%}%>
			</div>
		</td>

	</tr>
	<tr> 
		<td width="10%" class="thinborder"><div align="center"><font size="1"><strong>SIGNATORY - <br>SUB SIGNATORY</strong></font></div></td>
		<td width="10%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT 
				ID </strong></font></div>
		</td>
		<td width="16%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div>
		</td>
		<td width="10%" class="thinborder">
			<div align="center"><strong><font size="1">COURSE/YR</font></strong></div>
		</td>
		
		<td width="14%" class="thinborder">
			<div align="center"><strong><font size="1">DUE</font></strong></div>
		</td>
		<td width="12%" class="thinborder">
			<div align="center"><strong><font size="1">REMARKS</font></strong></div>
		</td>
		<td  class="thinborder" colspan="2">&nbsp;</td>
	</tr>
	<%
		for (int i = 0; i < vRetResult.size();i+=23){%>
	<tr> 
		<td class="thinborder"><font size="1">
		<%=WI.getStrValue((String)vRetResult.elementAt(i+17),"")%>&nbsp;-&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+18),"")%>
		</font></td>
		<td class="thinborder"><font size="1">
		<%if (i>0 && ((String)vRetResult.elementAt(i+4)).compareTo((String)vRetResult.elementAt(i-19))==0){%>
			&nbsp; 	<%}else{%><%=(String)vRetResult.elementAt(i+4)%><%}%></font></td>
		<td class="thinborder"><font size="1">
		<%if (i>0 && ((String)vRetResult.elementAt(i+4)).compareTo((String)vRetResult.elementAt(i-19))==0){%>
			&nbsp; 	<%}else{%><%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),7)%><%}%></font></td>
		<td class="thinborder"><font size="1">
		<%if (i>0 && ((String)vRetResult.elementAt(i+4)).compareTo((String)vRetResult.elementAt(i-19))==0){%>
			&nbsp; 	<%}else{%><%=(String)vRetResult.elementAt(i+5)%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","","&nbsp;")%><%}%></font></td>
		<td class="thinborder">
			<div align="left"><font size="1">Amount: <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"","","NONE")%><br>
		Quantity: <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"","&nbsp;","NONE")%><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;","","&nbsp;")%></font></div>
		</td>
		<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"","","NONE")%></font></td>
		<%if (vAuthIndex.indexOf(vRetResult.elementAt(i+16))==-1)
			bolIsAuth = false;
			else
			bolIsAuth = true;
			
			if(vRetResult.elementAt(i + 22).equals("0"))
				bolIsAuth = false;
			else
				bolIsAuth = true;
				
			
			%> 
		<td class="thinborder" width="5%"><font size="1"> 
        <% if((iAccessLevel ==2 || iAccessLevel == 3) && bolIsAuth){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
		<td class="thinborder" width="5%">
		<font size="1"> 
        <% if(iAccessLevel ==2 && bolIsAuth){%>
        <a href='javascript:PageAction("0","<%=WI.getStrValue((String)vRetResult.elementAt(i+15),"")%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
	</tr>
	<%}%>
</table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
      </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="ctype">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
