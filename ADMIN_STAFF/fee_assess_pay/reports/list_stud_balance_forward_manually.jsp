<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
	var oRows = document.getElementById('myTable1').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i) 
		 document.getElementById('myTable1').deleteRow(0);
	alert("Click OK to print this page");
	window.print();
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
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedger,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_balance_forward_manually.jsp");	
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
	FAStudentLedger studLedger = new FAStudentLedger();
	Vector vRetResult = null;
	String strTemp = null;
	
	if(WI.fillTextValue("proceed_").length() > 0) {
		vRetResult = studLedger.viewOldStudLedgerALL(dbOP, request);
		if(vRetResult == null)
			strErrMsg = studLedger.getErrMsg();
			
		//System.out.println(vRetResult);
	}
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";	
%>

<form method="post" action="./list_stud_balance_forward_manually.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: BALANCE FORWARD - MANUALLY ENCODED ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="show_summary" value="checked" <%=WI.fillTextValue("show_summary")%>> Show Summary
<%if(strSchCode.startsWith("UC")){%>
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="show_manually_encoded" value="checked" <%=WI.fillTextValue("show_manually_encoded")%>> Show only manually encoded
<%}%>	  
	  	<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("basic_con");
if(strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="basic_con" value=""<%=strErrMsg%>> Show ALL
<%
if(strTemp.equals("0")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="basic_con" value="0"<%=strErrMsg%>> Show Only College
<%
if(strTemp.equals("1")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input type="radio" name="basic_con" value="1"<%=strErrMsg%>> Show Only Basic	  </td>
    </tr>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  SY-Term: 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">

      
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Term</option>
<%}else{%>
          <option value="1">1st Term</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Term</option>
<%}else{%>
          <option value="2">2nd Term</option>
<%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Term</option>
<%}else{%>
          <option value="3">3rd Term</option>
<%}%>
        </select>
		&nbsp;&nbsp;&nbsp; 
        Student ID: 	  <input name="stud_id" type="text" size="16" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  
	  </td>
    </tr>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Transaction Date Range: 
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
       to
	    <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
<%if(strSchCode.startsWith("EAC")){%>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Particulars: 
	  		<select name="transaction_name">
		  		<option value=""></option>
    	      	<%=dbOP.loadCombo("LEDG_OLD_DATA_CATG.description","LEDG_OLD_DATA_CATG.description"," from LEDG_OLD_DATA_CATG order by LEDG_OLD_DATA_CATG.description", strTemp, false)%>
		  	</select>
		</td>
    </tr>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  College: 
	  		<select name="college">
		  		<option value=""></option>
					<%=dbOP.loadCombo("c_index","c_code, c_name"," from college where is_del = 0 order by c_code", WI.fillTextValue("college"), false)%>
		  	</select>
	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="73%"><input type="submit" name="_result" value="Show Result" onClick="document.form_.proceed_.value='1'"></td>
      <td width="23%" align="right" style="font-size:9px;">
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> Print Report 
	  <%}%>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><br>
        OLD ACCOUNT INFORMATION </div>
		<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#CCCCCC" align="center" style="font-weight:bold"> 
		  <td width="4%" class="thinborder"><font size="1">Count</font></td>
		  <td width="10%" class="thinborder"><font size="1">Student ID</font></td>
		  <td width="20%" height="25" class="thinborder"><font size="1">Student Name</font></td>
		  <td width="10%" class="thinborder"><font size="1">SY-Term</font></td>
		  <td width="12%" class="thinborder"><font size="1">Transaction Date</font></td>
		  <td width="34%" class="thinborder"><font size="1">Transaction Note</font></td>
		  <td width="10%" class="thinborder"><font size="1">Amount</font></td>
		</tr>
<%
String[] astrConvertTerm = {"SU","FS","SS","TS","Regular"};
if(WI.fillTextValue("basic_con").equals("1"))
	astrConvertTerm[1] = "Regular";

double dTotal = 0d;
boolean bolIsNegative = false;
for(int i = 0 ; i< vRetResult.size() ; i += 8){%>
		<tr>
		  <td class="thinborder"><%=i/8 + 1%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 4), "4"))]%>, <%=vRetResult.elementAt(i + 3)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
		  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
		  <td class="thinborder" align="right">
		  <%
			strTemp = (String)vRetResult.elementAt(i + 5);
			dTotal += Double.parseDouble(strTemp);
			
			if(strTemp.startsWith("-")) {
				bolIsNegative = true;
				strTemp = strTemp.substring(1);
			}
			else	
				bolIsNegative = false;
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(bolIsNegative)
				strTemp = "("+strTemp+")";
		  %>
		  <%=strTemp%>		  </td>
	    </tr>
<%}%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td style="font-size:11px; font-weight:bold;" align="right">Total: <%=CommonUtil.formatFloat(dTotal, true)%></td>
    	</tr>
  </table>	  
  
<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceed_">
</form>
</body>
</html>
