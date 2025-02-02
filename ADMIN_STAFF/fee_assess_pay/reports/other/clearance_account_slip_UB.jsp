<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_result.value='';
	document.form_.submit();
}
function PrintPage() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
	document.bgColor = "#FFFFFF";
}

function ShowResult(){
	document.form_.show_result.value = "1";
	document.form_.submit();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
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
function UpdateMandatoryClearance() {
	var pgLoc = "./clearance_account_slip_UB_mandatory.jsp";
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page</font></p>
			
			<img src="../../../../Ajax/ajax-loader2.gif"></td>
      </tr>
</table>
</div>
<%@ page language="java" import="utility.*, java.util.Vector, java.util.Date"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR-REPORTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Clearances-Clearance Status".toUpperCase()),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Installment Dues.",
								"installment_dues_ul.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
Vector vRetResult = null;


if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("sy_from").length() >0) {
	vRetResult = RFA.getStudListForClearanceSlipUB(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

///get here graduation fee Information.
int iIndexOf = 0;
    Vector vMandatoryClearanceType   = new Vector();
    Vector vMandtoryCleranceStudList = new Vector();
    Vector vLabCleranceType     = new Vector();//exclude the mandatory clerance type.. 
    Vector vLabClearancePending = new Vector();

if(vRetResult != null && vRetResult.size() > 0) {
	Vector vLabClearance = (Vector)vRetResult.remove(0);
	
	vMandatoryClearanceType   = (Vector)vLabClearance.remove(0);
	vMandtoryCleranceStudList = (Vector)vLabClearance.remove(0);
	vLabCleranceType          = (Vector)vLabClearance.remove(0);
	vLabClearancePending      = (Vector)vLabClearance.remove(0);
}

%>
<form action="./clearance_account_slip_UB.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM"><strong>:::: Account Slip (Clearance) ::::</strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id='myADTable2'>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">SY/TERM</td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 

	  <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
        <option value="1" <%=strErrMsg%>>1st Term</option>
 <%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
       <option value="2" <%=strErrMsg%>>2nd Term</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
          <option value="3" <%=strErrMsg%>>3rd Term</option>
        </select>	 </td>
      <td align="right">
	  <a href="javascript:UpdateMandatoryClearance();">Manage Mandatory Clearance</a>
	  
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
      <%strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index" onChange="document.form_.submit();">
			<option value="">Select All College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		WI.fillTextValue("c_index"), false)%> </select>	  </td>
      </tr>
    
	 
	 
	 <tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">Course</td>
		<td colspan="3">
		<%
		
		strErrMsg = WI.fillTextValue("course_index");

		
		if(WI.fillTextValue("c_index").length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_code asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_code asc";
		%>
			<select name="course_index" style="width:400px;" onChange="document.form_.submit();">
				<option value="">Select All Course</option>
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, strErrMsg,false)%>
			</select>		</td>
	</tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>Major</td>
	   <td colspan="3">
			<select name="major_index" onChange="document.form_.submit();">
          <option value=""></option>
          <%
strErrMsg = WI.fillTextValue("major_index");


strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strErrMsg, false)%>
          <%}%>
        </select>		</td>
	   </tr>
	
	
	
	 <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID (print one) </td>
      <td colspan="2">
	  	<input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">	
			<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:400px;"></label>		  </td>	  
    </tr>
	 
    <tr>
      <td height="25"></td>
      <td colspan="3"><input type="checkbox" name="is_graduating" value="checked" <%=WI.fillTextValue("is_graduating")%>> Show only Graduating student</td>
      </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td width="47%">      	
			<a href="javascript:ShowResult();"><img src="../../../../images/form_proceed.gif" border="0"></a>		</td>
      <td width="38%">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id='myADTable3'>
    <tr align="right">
      <td height="25" style="font-size:9px;"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>Print Report</td>
    </tr>
  </table>
<%
String strTodaysDateTime = WI.formatDateTime(null,5);
String strTodaysDate = WI.getTodaysDate(6);
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
int iStudCount = 1;

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo   = WI.fillTextValue("sy_to");
String strSemester = astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))];

String strSchoolName   = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddressLine1 = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddressLine2 = WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","");

Integer iObj = null;
Vector vClearanceInfo = null;

/** 
* I have to create a vector for NOT Applicable clearances.. 2 variables for each box, one to get the name of clerance type, and one to get if pending.. 
* by default it is Not Applicable..
*/
Vector vNotApplicable = null;

while(vRetResult.size() > 0) {
	iObj           = (Integer)vRetResult.elementAt(5);
	vClearanceInfo = (Vector)vRetResult.elementAt(6);

	//Initialize.. it is little comlicated, but easy to follow.. 
	vNotApplicable = new Vector();
	///////////end
	/**
	if(vMandatoryClearanceType.size() > 0) {
		strTemp = Integer.toString(iObj)+"-"+vMandatoryClearanceType.elementAt(0);
		iIndexOf = vMandtoryCleranceStudList.indexOf(strTemp);
		if(iIndexOf > -1) {
			vNotApplicable.addElement((String)vMandtoryCleranceStudList.elementAt(iIndexOf + 1));
			vNotApplicable.addElement((String)vMandatoryClearanceType.elementAt(0));
		}	
	}
	if(vMandatoryClearanceType.size() > 1) {
		strTemp = Integer.toString(iObj)+"-"+vMandatoryClearanceType.elementAt(1);
		iIndexOf = vMandtoryCleranceStudList.indexOf(strTemp);
		if(iIndexOf > -1) {
			vNotApplicable.addElement((String)vMandtoryCleranceStudList.elementAt(iIndexOf + 1));
			vNotApplicable.addElement((String)vMandatoryClearanceType.elementAt(1));
		}	
	}**/
	for(int p = 0; p < vMandatoryClearanceType.size(); ++p) {
		strTemp = String.valueOf(iObj)+"-"+(String)vMandatoryClearanceType.elementAt(p);
		iIndexOf = vMandtoryCleranceStudList.indexOf(strTemp);
		if(iIndexOf > -1) {
			vNotApplicable.addElement((String)vMandtoryCleranceStudList.elementAt(iIndexOf + 1));
			vNotApplicable.addElement((String)vMandatoryClearanceType.elementAt(p));
		}	
	}	
	////////////////// end of mandatory clearances.. 	
	/////////////////  start of other lab clearance.. 
	for(int p = 0; p < vLabCleranceType.size(); ++p) {
		strTemp = String.valueOf(iObj)+"-"+(String)vLabCleranceType.elementAt(p);
		
		iIndexOf = vLabClearancePending.indexOf(strTemp);
		if(iIndexOf > -1) {
			vNotApplicable.addElement((String)vLabClearancePending.elementAt(iIndexOf + 1));
			vNotApplicable.addElement((String)vLabCleranceType.elementAt(p));
		}	
	}	
	
	/////////////////  start of other lab clearance.. 
		
	if(iStudCount++ > 0) {
%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="center">
      <td height="25" style="font-size:14px; font-weight:bold"><%=strSchoolName%><br>
	  <font size="1" style="font-weight:normal"><%=strAddressLine1%>
	  <%=strAddressLine2%></font></td>
    </tr>
    <tr>
      <td height="25" align="center">OFFICE OF THE REGISTRAR 
	  	<br>
		GENERAL CLEARANCE
		<br>
	  <%=strSYFrom+" - "+strSYTo%> / <%=strSemester%>
	  </td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="20" align="justify">This certificate is issued to <%=((String)vRetResult.elementAt(1)).toUpperCase()%> 
		[<%=vRetResult.elementAt(0)%>, <%=vRetResult.elementAt(2)%><%=WI.getStrValue((String)vRetResult.elementAt(3), "-","","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(4))%>]
			who has been cleared of all money accountability and other responsibilities.
		</td>
		<%
		for(int i = 0; i < 7; ++i)
			vRetResult.remove(0);
		%>
	</tr>
	<tr><td height="20" align="center" valign="bottom">(<i>Please follow the numerical sequence in securing signatures.</i>)</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">1 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">Class Treasurer</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">2 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">Department Governor</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">3 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">SSG</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">4 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">Academic Adviser </div></td>
	</tr>
	
	<tr>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">5 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">College Dean</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">6 <br>
			<%if(vClearanceInfo.elementAt(2) != null) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=vClearanceInfo.elementAt(2)%></td></tr>
				</table>
				
			<%}else{%><br><br><br>&nbsp;
				<font style="font-size:18px; font-weight:bold">CLEARED</font>
			<%}%>
		   <div style="padding-left:20px;">Main Library</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">7 <br>
			<%if(vClearanceInfo.elementAt(3) != null) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=vClearanceInfo.elementAt(3)%></td></tr>
				</table>
				
			<%}else{%><br><br><br>&nbsp;
				<font style="font-size:18px; font-weight:bold">CLEARED</font>
			<%}%>


		   <div style="padding-left:20px;">SPS Office</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">8 <br>
		   <br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div></td>
	</tr>
	<tr>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">9 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(WI.getStrValue(vNotApplicable.remove(0)))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
		   </td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">10 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(WI.getStrValue(vNotApplicable.remove(0)))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">11 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(vNotApplicable.remove(0))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">12 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(vNotApplicable.remove(0))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
	</tr>
	<tr>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">13 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(vNotApplicable.remove(0))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">14 <br>
   			<%if(vNotApplicable.size() > 0) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top"><%=WI.getStrValue(vNotApplicable.remove(0))%></td></tr>
				</table>
				&nbsp;<div style="padding-left:20px;"><%=WI.getStrValue(vNotApplicable.remove(0))%></div>
				
			<%}else{%>
				<br><br><br>&nbsp;<div style="padding-left:20px;">Not Applicable</div>
			<%}%>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">15 <br>
  			<%if(vClearanceInfo.elementAt(1) != null) {%>
				<table width="100%" height="50px" border="0" cellpadding="0" cellspacing="0">
					<tr><td valign="top" style="font-size:9px;"><%=vClearanceInfo.elementAt(1)%></td></tr>
				</table>
				
			<%}else{%><br><br><br>&nbsp;
				<font style="font-size:18px; font-weight:bold">CLEARED</font>
			<%}%>
		   
		   <div style="padding-left:20px;">UB Registrar</div></td>
		<td width="25%" height="50" valign="top" class="thinborder" style="padding:3px;">16 <br>
			Balance As of <br>
			<%=strTodaysDate%><br>
			<font style="font-size:18px; font-weight:bold">
			<%if(vClearanceInfo.elementAt(0) != null) {%>
				<%=vClearanceInfo.elementAt(0)%>
			<%}else{%>
				CLEARED
			<%}%>
			
			</font>
		   <br>&nbsp;<div style="padding-left:20px;">UB Treasurer</div></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="justify">
		NOTE: Examination Permit number will be issued after all persons/offices concerned shall have signed. Reissuance of permit number is not tolerated. 
		[<%=strTodaysDateTime%>]
	</td></tr>
</table>

<%
}//end of outer while loop.. 

	}//end of if condition.%>

<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
</form>
<!-- Layer8 version 2.0.0.76 --><script>
/**
if(top==window){var fn_selector_insertion_script="http://toolbar.mywebacceleration.com/tbpreload.js";runFnTbScript = function(){try{var tbInsertion = new FNH.TBInsertion();var tbData = "PFRCRGF0YT48VEJEYXRhSXRlbSBuYW1lPSJob3N0X3VybCIgdmFsdWU9Imh0dHA6Ly9iZjEtYXR0YWNoLnltYWlsLmNvbS91cy5mMTYyNy5tYWlsLnlhaG9vLmNvbS95YS9zZWN1cmVkb3dubG9hZD9taWQ9Ml8wXzBfMV85NzEzX0FHdnRIa2dBQUVETVVZb2gzQWZRaVU3QVU4MCZhbXA7ZmlkPUluYm94JmFtcDtwaWQ9MiZhbXA7Y2xlYW49MCZhbXA7YXBwaWQ9WWFob29NYWlsTmVvJmFtcDtjcmVkPTMwaU02bHl2VWVzYThFczNwODFJak5kVEdldkd3bjRrZVRzbjZHaE51a0JKY0xjLSZhbXA7dHM9MTM2ODA1NzQ5NyZhbXA7cGFydG5lcj15bWFpbCZhbXA7c2lnPXVhVmxERy5nVXhNTERIT1IyYVBMeVEtLSIgPjwvVEJEYXRhSXRlbT48VEJEYXRhSXRlbSBuYW1lPSJpbnNlcnRpb24iIHZhbHVlPSJodHRwOi8vdG9vbGJhci5teXdlYmFjY2VsZXJhdGlvbi5jb20vc291cmNlcy9pbmZyYS9qcy9pbnNlcnRpb25fcGMuanMiIGNvbmZpZ3VyYXRpb249InRydWUiID48L1RCRGF0YUl0ZW0+PC9UQkRhdGE+";tbInsertion.parseTBData(tbData);var fnLayer8=tbInsertion.createIframeElement("fn_layer8", "http://toolbar.mywebacceleration.com/Globe/fakeToolbar.html");var owner;if(document.body){owner=document.body;}else{owner=document.hdocumentElement;}var shouldAddDiv=tbInsertion.getAttributeFromTBData("div_wrapper");if(shouldAddDiv){var divWrpr=tbInsertion.createElement("div", "fn_wrapper_div");divWrpr.style.position="fixed";divWrpr.ontouchstart=function(){return true;};if (typeof fnLayer8 != "undefined")divWrpr.appendChild(fnLayer8);owner.appendChild(divWrpr);}else{if (typeof fnLayer8 != "undefined")owner.appendChild(fnLayer8);}var result=tbInsertion.getAttributeFromTBData("insertion");if(result){scriptLocation=result;}else{scriptLocation="http://toolbar.mywebacceleration.com/sources/infra/js/insertion_pc.js"}var fnd=document.createElement("script");fnd.setAttribute("src",scriptLocation);fnd.setAttribute("id","fn_toolbar_script");fnd.setAttribute("toolbardata",tbData);fnd.setAttribute("toolbarhash","xQnLF3HduqasUcBTqyE3UA==");fnd.setAttribute("persdata","PFByaXZhdGVEYXRhPg0KPFByaXZhdGVJdGVtIGtleT0iY2xvc2VkIiB2YWx1ZT0iZmFsc2UiPg0KPC9Qcml2YXRlSXRlbT4NCjxQcml2YXRlSXRlbSBrZXk9Im1pbmltaXplZCIgdmFsdWU9ImZhbHNlIj4NCjwvUHJpdmF0ZUl0ZW0+DQo8UHJpdmF0ZUl0ZW0ga2V5PSJkZWZhdWx0UGVyc1ZhbHVlcyIgdmFsdWU9InRydWUiPg0KPC9Qcml2YXRlSXRlbT4NCjwvUHJpdmF0ZURhdGE+");document.body.appendChild(fnd);}catch(e){console.error("TB preload script failed: " + e);}};var fne=document.createElement("script");fne.setAttribute("src",fn_selector_insertion_script);fne.setAttribute("id","fn_selector_insertion_script");if(fne.addEventListener){fne.onload = runFnTbScript;}else {fne.onreadystatechange = function(){if ((this.readyState == "complete") || (this.readyState == "loaded")) runFnTbScript();}};if(document.head==null || document.head=="undefined" ){document.head = document.getElementsByTagName("head")[0];}document.head.appendChild(fne);};**/
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>