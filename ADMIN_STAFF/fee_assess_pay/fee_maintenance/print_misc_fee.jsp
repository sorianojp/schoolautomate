<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	//strSchCode = "UC";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.textbox_noborder2{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		border:none;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}
function ShowFee() {
	document.form_.show_fee.value = "1";
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}

function SetFocusIndex(strIndex){
	document.form_.focus_index.value = strIndex;
}

function CheckUpdate(strIndex){

/** Moved to Ajax call 	if (eval('document.form_.misc'+strIndex+'.value != document.form_.misc_o'+strIndex+'.value')){
		eval('document.form_.info_index.value = document.form_.info_index'+strIndex+'.value');
		eval('document.form_.amount_new.value = document.form_.misc'+strIndex+'.value');
		this.SubmitOnce('form_');
	}
**/

	var strNewAmount = "";
	var strOldAmount = "";
	var strInfoIndex = "";

	eval('strNewAmount=document.form_.misc'+strIndex+'.value');
	eval('strOldAmount=document.form_.misc_o'+strIndex+'.value');
	eval('strInfoIndex=document.form_.info_index'+strIndex+'.value');

	if (strNewAmount != strOldAmount){
		document.form_.info_index.value = strInfoIndex;
		document.form_.amount_new.value = strNewAmount;
		///this.SubmitOnce('form_');
		//changed to ajax call..
		var objAmount;
		eval('objAmount=document.form_.misc'+strIndex);

		this.InitXmlHttpObject(objAmount, 1);//I want to get value in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=101&amount_new="+strNewAmount+
		"&info_index="+strInfoIndex+"&is_tuition=2";
		this.processRequest(strURL);
	}

}
function GoPerSubjFee() { 
	<%if(strSchCode.startsWith("UC")){%>
		location = "./print_oth_charge_per_subj_fee_uc.jsp?sy_from="+document.form_.sy_from.value+
					"&sy_to="+document.form_.sy_to.value;
	<%}else{%>
		location = "./print_oth_charge_per_subj_fee.jsp?sy_from="+document.form_.sy_from.value+
					"&sy_to="+document.form_.sy_to.value;
	<%}%>
}
function GoPerMiscFee() {
	location = "./print_misc_fee_per_fee_name.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","print_misc_fee.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"print_misc_fee.jsp");
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

FAFeeMaintenance FA = new FAFeeMaintenance();
Vector vRetResult = null;
int iCtr = 0;

boolean bolIsVMUF   = strSchCode.startsWith("VMUF");
boolean bolIsFatima = strSchCode.startsWith("FATIMA");
boolean bolIsUC     = strSchCode.startsWith("UC");
boolean bolIsVMA    = strSchCode.startsWith("VMA");
boolean bolIsDLSHSI = strSchCode.startsWith("DLSHSI");

String strReadOnly = "";

if (!strSchCode.startsWith("CPU")){
	strReadOnly = " readonly ";
}

if(WI.fillTextValue("show_fee").length() == 0 && WI.fillTextValue("sy_from").length() > 0) {

/** moved to AJAX call..
	if (WI.fillTextValue("info_index").length() > 0
		&& WI.fillTextValue("amount_new").length() > 0) {
		String strAmount = WI.fillTextValue("amount_new");
		try{
			strAmount = ConversionTable.replaceString(strAmount,",","");
			Float.parseFloat(strAmount);

			java.sql.ResultSet rs = dbOP.executeQuery("select amount, amt_per_unit"  +
			" from fa_misc_fee where MISC_FEE_INDEX = " + WI.fillTextValue("info_index"));
			if (rs.next()){
				if (rs.getDouble(1) > 0d) {
					rs.close();
				dbOP.executeUpdateWithTrans("update fa_misc_fee set amount =" + strAmount +
				", last_mod_by = " + (String)request.getSession(false).getAttribute("userIndex") +
				", last_mod_date = '" + WI.getTodaysDate() +
				"' where MISC_FEE_INDEX = " + WI.fillTextValue("info_index"),null,null, false);
  			  }else{
			  		rs.close();
				dbOP.executeUpdateWithTrans("update fa_misc_fee set AMT_PER_UNIT =" + strAmount +
				", last_mod_by = " + (String)request.getSession(false).getAttribute("userIndex") +
				", last_mod_date = '" + WI.getTodaysDate() +
				"' where MISC_FEE_INDEX = " + WI.fillTextValue("info_index"),null,null, false);

			  }
			}else{
			rs.close();
			}



//			System.out.println("update fa_tution_fee set amount =" + strAmount +
//				", last_mod_by = " + (String)request.getSession(false).getAttribute("userIndex") +
//				", last_mod_date = '" + WI.getTodaysDate() +
//				"' where tution_fee_index = " + WI.fillTextValue("info_index"));


		}catch(NumberFormatException nfe){
			strErrMsg = " Invalid Miscellaneous amount : " + strAmount;
		}catch(java.sql.SQLException sqlE){
			strErrMsg = " Unable to view record. Please refresh page and try again.";
		}


	}
**/


	vRetResult = FA.printMiscFee(dbOP, request);
	if(vRetResult == null)
		strErrMsg = FA.getErrMsg();
}

String strSYFrom = null;
	strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%> 


<form name="form_" action="./print_misc_fee.jsp" method="post">
<input type="hidden" name="focus_index" value="<%=WI.fillTextValue("focus_index")%>">
<input type="hidden" name="amount_new" value="">
<input type="hidden" name="oth_charge" value="<%=WI.getStrValue(WI.fillTextValue("oth_charge"),"0")%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          <%if(WI.fillTextValue("oth_charge").compareTo("1") == 0){%>OTHER CHARGES<%}else{%>MISCELLANEOUS FEES<%}%> PRINT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="22" colspan="5">&nbsp;&nbsp;<b><font size="3"><%=strErrMsg%></font></b></td>
    </tr>
 <%
if(strSchCode.startsWith("CIT") && !WI.fillTextValue("oth_charge").equals("1")) {%>
    <tr style="font-weight:bold; color:#0000FF;">
      <td height="25">&nbsp;</td>
      <td colspan="4">Applicable SY Range<font style="font-weight:bold; color:#FF0000">*</font> :
	  <select name="id_sy_range" onChange="ReloadPage();">
          <%=dbOP.loadCombo("ID_RANGE_INDEX","RANGE_SY_FROM,RANGE_SY_TO"," from FA_CIT_IDRANGE where IS_ACTIVE_RECORD=1 and eff_fr_sy = "+strSYFrom+" order by RANGE_SY_FROM asc", WI.fillTextValue("id_sy_range"), false)%> 
	  </select>	 
	   
<strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>	  
	  
	  </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="22">&nbsp;</td>
      <td width="9%">School year </td>
      <td width="29%">
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
   <%
	strTemp = request.getParameter("sy_to");
	if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  -
	  
	  <%
strTemp = WI.fillTextValue("semester");
if(request.getParameter("semester") == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");	

if(strTemp == null)
	strTemp = "";
%>
	  <select name="semester">
          <option value="0">Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Term</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Term</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";	
else
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Term</option>
        </select>
	  
	  </td>
      <td width="25%"><a href="javascript:ReloadPage();"><img src="../../../images/view.gif" border="0"></a>
	  <input type="checkbox" name="set_xls" value="checked" <%=WI.fillTextValue("set_xls")%>> set .xls compatible
	  </td>
      <td width="35%">
	  <%if(strSchCode.startsWith("CIT") || true){%>
		  <%if(WI.fillTextValue("oth_charge").compareTo("1") == 0){%>
			<a href="javascript:GoPerSubjFee();">Go to Per Subject Fee with Category</a>
		  <%}
		  else{%>
			<a href="javascript:GoPerMiscFee();">Display Per Misc Fee</a>
		  <%}%>
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Course </td>
      <td colspan="3">
  <%
	strTemp = request.getParameter("course_index");
	if(strTemp == null || strTemp.compareTo("selany") == 0) strTemp = "";
	%> <select name="course_index" onChange="ReloadPage();">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>Major </td>
      <td colspan="3"><select name="major_index">
          <option></option>
    <%
if(strTemp != null && strTemp.compareTo("selany") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" align="right">
        <% if(vRetResult != null && vRetResult.size() > 0) {%>
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">
        Print page.</font>&nbsp;&nbsp;&nbsp;&nbsp;
        <%}%>      </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{
String[] convertYearLevel = {"All YEAR","1ST YEAR","2ND YEAR","3RD YEAR","4TH YEAR","5TH YEAR","6TH YEAR","7TH YEAR","8TH YEAR"};
String[] strConvertSem    = {"SUMMER","1ST","2ND","3RD","4TH","ALL"};
String[] astrConvertToFeeType = {"Per Unit","Per Type","Per Hour","Amt*UE"};
String strOptional = null;
String strHandsOn = null;
boolean bolCourseMustBeNull = false;

String strIsGraduating = null;
String strIsAttcnbStud = null;
String strIsReturnee   = null;
double dSubTotal = 0d;

boolean bolSetXLS = false;
if(WI.fillTextValue("set_xls").length() > 0) 
	bolSetXLS = true;

for (int i = 0; i < vRetResult.size();) {bolCourseMustBeNull = false;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td height="22" colspan="11" class="thinborder"><div align="center"><strong><font size="1">LIST
          OF <%if(WI.fillTextValue("oth_charge").compareTo("1") == 0){%>OTHER CHARGES<%}else{%>MISCELLANEOUS FEES<%}%> <b>FOR <%=WI.fillTextValue("sy_from") +" - "+WI.fillTextValue("sy_to")%><br>
          <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),(String)vRetResult.elementAt(i)+":::","",
		  (String)vRetResult.elementAt(i))%></b></font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="47%" height="22" class="thinborder"><div align="center"><font size="1"><strong>FEE NAME</strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">HANDSON SUB CATG</font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>FEE AMOUNT </strong></font></div></td>
      <td width="16%" align="center" class="thinborder"><strong><font size="1">FEE CHARGE TYPE</font></strong></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>SEM</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>CHARGED ONCE</strong></font></div></td>
      <td width="16%" class="thinborder"><font size="1"><strong>ONLY FOR FOREIGN STUDENT</strong></font></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>ONLY FOR NEW </strong></font></div></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>ONLY FOR OLD</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong><font size="1">YEARLY FEE</font></strong></font></td>
<%if(bolIsVMUF){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Gender</td>
<%}if(bolIsFatima){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Is Graduating </td>
<%}if(bolIsUC){%>
     <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Is ATTC/NB </td>
<%}if(bolIsVMA){%>
     <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Returnee</td>
<%}if(bolIsDLSHSI){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Charge Reg/Irreg </td>
<%}%>
    </tr>
    <%
for(; i< vRetResult.size() ; i+=22) {
if(bolCourseMustBeNull && vRetResult.elementAt(i) != null) {
	%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    		<tr>
				<td style="font-weight:bold;" class="thinborderNONE"> Total Misc Fee: <%=CommonUtil.formatFloat(dSubTotal, true)%></td>
			</tr>
		  </table>
	
	<%dSubTotal = 0d;
	break;
}
//if year level is not null, i have to show what is year level.

	if(vRetResult.elementAt(i + 18).equals("1"))
		strIsGraduating = "<font style='font-size:12px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsGraduating = "&nbsp;";
	
	if(vRetResult.elementAt(i + 19).equals("1"))
		strIsAttcnbStud = "<font style='font-size:14px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsAttcnbStud = "&nbsp;";

	if(vRetResult.elementAt(i + 20).equals("1"))
		strIsReturnee = "<font style='font-size:14px; color=red; font-weight:bold'>Y</font>";
	else	
		strIsReturnee = "&nbsp;";

	dSubTotal += Double.parseDouble(WI.getStrValue(ConversionTable.replaceString((String)vRetResult.elementAt(i + 8), ",", ""), "0"));
	

if(vRetResult.elementAt(i + 2) != null) {%>
    <tr bgcolor="#FFFFDF">
      <td height="19" class="thinborder"> <strong><font size="1">YEAR
        LEVEL :::: <%=convertYearLevel[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></font></strong></td>
      <td height="19" class="thinborder" align="center">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
      <td height="19" class="thinborder">&nbsp;</td>
<%if(bolIsVMUF){%>
      <td class="thinborder">&nbsp;</td>
<%}if(bolIsFatima){%>
      <td class="thinborder">&nbsp;</td>
<%}if(bolIsUC){%>
      <td align="center" class="thinborder">&nbsp;</td>
<%}if(bolIsVMA){%>
      <td align="center" class="thinborder">&nbsp;</td>
<%}if(bolIsDLSHSI){%>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
    <%}%>
    <tr>
      <td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%
	  if(((String)vRetResult.elementAt(i+4)).compareTo("1") ==0){//hands on.%> <%=WI.getStrValue((String)vRetResult.elementAt(i+3),"(",")","")%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder">
	  <%if(bolSetXLS) {%>
	  	<%=(String)vRetResult.elementAt(i + 8)%>
	  <%}else{%>
		<input name="misc<%=iCtr%>" type="text" size="9" class="textbox_noborder2"
			onBlur="CheckUpdate(<%=iCtr%>);style.backgroundColor='white'"
			value="<%=(String)vRetResult.elementAt(i + 8)%>"
			onfocus="SetFocusIndex(<%=iCtr%>);style.backgroundColor='#D3EBFF'" <%=strReadOnly%>>
	  <%}%>
		<input type="hidden" name="misc_o<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i + 8)%>">
		<input type="hidden" name="info_index<%=iCtr++%>" value="<%=(String)vRetResult.elementAt(i + 16)%>">	   </td>
      <td align="center" class="thinborder"><%=astrConvertToFeeType[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td>
      <td align="center" class="thinborder"><%=strConvertSem[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+13),"5"))]%></td>
      <td align="center" class="thinborder"><%
	  if(((String)vRetResult.elementAt(i+12)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%></td>
      <td align="center" class="thinborder"> <%
	  if(((String)vRetResult.elementAt(i+11)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"(",")","")%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder" style="font-size:8px; color:blue"> 
	  <%
	  strTemp = (String)vRetResult.elementAt(i+9);
	  if(strTemp.equals("0"))
		  strTemp = "&nbsp;";
	  else if(strTemp.equals("1"))
	  	strTemp = "<img src='../../../images/tick.gif'";
	  else if(strTemp.equals("2"))
	  	strTemp = "Cross Enrollee";
	  else if(strTemp.equals("3"))
	  	strTemp = "Transferee";
	  else	
		  strTemp = "&nbsp;";
	  %> <%=strTemp%></td>
      <td align="center" class="thinborder"> <%
	  if(((String)vRetResult.elementAt(i+15)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder"> <%
	  if(((String)vRetResult.elementAt(i+10)).compareTo("1") ==0){%> <img src="../../../images/tick.gif"> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsVMUF){%>
      <td align="center" class="thinborder">
		<%
		strTemp = 	(String)vRetResult.elementAt(i+17);
		if(strTemp == null)
			strTemp = "&nbsp;";
		else {
			if(strTemp.equals("0"))
				strTemp = "M";
			else
				strTemp = "F";
		}%>
        <%=strTemp%>	  </td>
<%}if(bolIsFatima){%>
      <td align="center" class="thinborder"><%=strIsGraduating%></td>
<%}if(bolIsUC){%>
      <td align="center" class="thinborder"><%=strIsAttcnbStud%></td>
<%}if(bolIsVMA){%>
      <td align="center" class="thinborder"><%=strIsReturnee%></td>
<%}if(bolIsDLSHSI){
strTemp = (String)vRetResult.elementAt(i+21);
if(strTemp.equals("0"))
	strTemp = "All";
else if(strTemp.equals("1")) 
	strTemp = "Reg";
else
	strTemp = "Irreg";
%>
      <td align="center" class="thinborder"><%=strTemp%></td>
<%}%>
    </tr>
    <%
	bolCourseMustBeNull = true;
	}//end of displaying levels
%>
  </table>
<%//if there i < vRetResult, print 1 line space.
if(i < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<table width="100%" bgcolor="#FFFFFF"><tr>
      <td>&nbsp;
      </td>
    </tr></table>
<%}
	}//end of for loop outer

}//end of if vRetResult is not null.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
  </table>


<script language="javascript">
	if (document.form_.focus_index.value.length > 0)
		eval("document.form_.misc" + document.form_.focus_index.value +".focus()");
</script>

<input type="hidden" name="info_index" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
