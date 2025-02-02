<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.student_id.value;
		if(strCompleteName.length < 2 )
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.student_id.value = strID;
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function PageAction(strAction , strinfo){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}

	document.form_.page_action.value = strAction;
	document.form_.searchStudent.value='4';
	
	if(strinfo.length > 0)
		document.form_.info_index.value = strinfo;
	
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	ConstructSearch consearch = new ConstructSearch();

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
<%
		return;
	}

FAStudentLedgerExtn faLedgExtn = new FAStudentLedgerExtn();

String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
 
 Vector vRetResult = null;

  strTemp = WI.fillTextValue("page_action");
  if(strTemp.length() > 0)
	{  if(faLedgExtn.getOTRPaymentException(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = faLedgExtn.getErrMsg();
		else
		{   if(strTemp.equals("1"))
			  strErrMsg = "Entry Successfully saved.";
		    if(strTemp.equals("0"))
			  strErrMsg = "Entry Successfully deleted.";	
		}
	 }
	if(WI.fillTextValue("searchStudent").length() > 0){
		vRetResult = faLedgExtn.getOTRPaymentException(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = faLedgExtn.getErrMsg();
 	}
%>
<form name="form_" action="otr_print_exception.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: OTR PRINT EXCEPTION ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="25" colspan="9">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td colspan="7"><input name="student_id" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("student_id")%>" size="16"  onKeyUp="AjaxMapName('1');">
        <label id="coa_info" style="font-size:11px; position:absolute; width:300px; font-weight:bold;"></label>
      </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Allow Reason</td>
      <td colspan="7"><textarea name="reason" cols="50" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea>
      </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Valid Until</td>
      <td colspan="7"><input name="date_until" type="text" class="textbox" id="date_until" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("date_until")%>" size="10">
        <a href="javascript:show_calendar('form_.date_until');"> <img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr>
      <td height="10" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="11%" height="15"><a href="javascript:PageAction('1','')"> <img src="../../../../../images/save.gif"  border="0" /></a></td>
      <td width="75%" colspan="2"><a href="./otr_print_exception.jsp"><img src="../../../../../images/cancel.gif" 
		  border="0"></a> <font size="1">click to cancel/clear entries </font>
        </div></td>
    </tr>
    <tr>
      <td height="19" colspan="9"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable" >
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%" class="thinborderTOPLEFT" bgcolor="#DDDDDD">Student ID</td>
      <td height="25" colspan="6" class="thinborderTOPRIGHT" bgcolor="#DDDDDD"><select name="stud_id_con">
          <%=consearch.constructGenericDropList(WI.fillTextValue("stud_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="stud_id" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="" size="16">
      </td>
      <td width="3%"></td>
    </tr>
    <tr>
      <td></td>
      <td height="5" colspan="7" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td width="10%" class="thinborderLEFT" bgcolor="#DDDDDD">Lastname</td>
      <td colspan="6" class="thinborderRIGHT" bgcolor="#DDDDDD"><select name="lname_con">
          <%=consearch.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="lname" type="text" size="16" value="" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
      <td width="3%"></td>
    </tr>
    <tr>
      <td></td>
      <td height="5" colspan="7" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td width="10%" class="thinborderLEFT" bgcolor="#DDDDDD">Firstname</td>
      <td colspan="4" bgcolor="#DDDDDD"><select name="fname_con">
          <%=consearch.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="fname" type="text" size="16" value="" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
      <td width="11%" bgcolor="#DDDDDD">Valid Date </td>
      <td width="45%" class="thinborderRIGHT" bgcolor="#DDDDDD"><input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="" size="10">
        <a href="javascript:show_calendar('form_.date_from');"> <img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="" size="10" readonly="yes" />
        <a href="javascript:show_calendar('form_.date_to');"> <img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0" /></a></td>
      <td width="3%"></td>
    </tr>
    <tr>
      <td></td>
      <td height="5" colspan="7" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td width="10%" class="thinborderLEFT" bgcolor="#DDDDDD">Course</td>
      <td colspan="6" class="thinborderRIGHT" bgcolor="#DDDDDD"><select name="course_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name "," from course_offered  where IS_DEL=0 and is_valid=1 order by course_name asc", WI.fillTextValue("course_index"), false)%>
        </select>
      </td>
      <td width="3%"></td>
    </tr>
    <tr>
      <td></td>
      <td height="5" colspan="7" class="thinborderLEFTRIGHT" bgcolor="#DDDDDD"></td>
      <td></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td width="10%" class="thinborderBOTTOMLEFT" bgcolor="#DDDDDD">Year Level</td>
      <td colspan="4" class="thinborderBOTTOM" bgcolor="#DDDDDD"><% strTemp = WI.fillTextValue("year_level");%>
        <select name="year_level">
          <option value="">N/A</option>
          <%
		    if(strTemp.equals("1"))
			    strErrMsg = " selected";
		    else
			    strErrMsg = "";
          %>
          <option value="1" <%=strErrMsg%>>1st</option>
          <%
		    if(strTemp.equals("2"))
			    strErrMsg = " selected";
		    else
			    strErrMsg = "";
          %>
          <option value="2" <%=strErrMsg%>>2nd</option>
          <%
		    if(strTemp.equals("3"))
			   strErrMsg = " selected";
		    else
			   strErrMsg = "";
          %>
          <option value="3" <%=strErrMsg%>>3rd</option>
          <%
		    if(strTemp.equals("4"))
			   strErrMsg = " selected";
		    else
			   strErrMsg = "";
          %>
          <option value="4" <%=strErrMsg%>>4th</option>
          <%
		    if(strTemp.equals("5"))
			   strErrMsg = " selected";
		    else
			   strErrMsg = "";
          %>
          <option value="5" <%=strErrMsg%>>5th</option>
          <%
		    if(strTemp.equals("6"))
			   strErrMsg = " selected";
		    else
			   strErrMsg = "";
          %>
          <option value="6" <%=strErrMsg%>>6th</option>
        </select></td>
      <td class="thinborderBOTTOM" bgcolor="#DDDDDD"><input type="button" name="search" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.searchStudent.value='4';document.form_.submit();">
      </td>
      <td class="thinborderBOTTOMRIGHT" bgcolor="#DDDDDD"></td>
      <td width="3%"></td>
    </tr>
    <tr>
      <td height="10" colspan="8">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="7" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>::: OTR PAYMENT EXCEPTION LIST ::: </strong></div></td>
    </tr>
    <tr bgcolor="#CCCCCC">
      <td width="15%" class="thinborder" height="20">&nbsp;<font size="1"><strong>Student ID</strong></font></td>
      <td width="20%" class="thinborder"><font size="1"><strong>Name</strong></font></td>
      <td width="30%" class="thinborder"><font size="1"><strong>Reason</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Valid Until</strong></font></td>
      <td width="15%" class="thinborder"><font size="1"><strong>OTR Printed by</strong></font></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Delete</strong></font></td>
    </tr>
    <% for (int i=0; i< vRetResult.size(); i+=8){%>
    <tr>
      <td class="thinborder" height="20">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1">
      <% if(vRetResult.elementAt(i+5).equals("1")) {%>
	   Not Authorized
       <% } else {%>
        <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif"  border="0"/></a>
      <%}%>
      </font></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action"/>
  <input type="hidden" name="searchStudent" value="<%=WI.fillTextValue("searchStudent")%>"/>
  <input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
