<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRLeaveConversion, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Conversion By Batch</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function PostConversion(){
  var vProceed = confirm('Post selected records in payroll?');
  if(vProceed){
		document.form_.page_action.value = "5";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
	if(eval(vItems) > 16){
		document.form_.copy_all.value = "1";
		document.form_.print_page.value = "";
		document.form_.searchEmployee.value = "1";		
		this.SubmitOnce('form_');
	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.conv_days_'+i+'.value=document.form_.conv_days_1.value');			
	}
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	boolean bolWithSchedule = WI.fillTextValue("with_schedule").equals("1");
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	String strHasWeekly  = null;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Leave Conversion(batch)","leave_conversion_doe.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"leave_conversion_doe.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","LEAVE CONVERSION",request.getRemoteAddr(),"leave_conversion_doe.jsp");
}
														
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PRLeaveConversion prConversion = new PRLeaveConversion();
	PReDTRME prEdtrME = new PReDTRME();
	String strCutOff = null;
		double dAmount = 0d;
	double dDays = 0d;
	int iSearchResult = 0;
	int i = 0;
	String strSchCode = dbOP.getSchoolIndex();
	
	String strWithSched = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
	String strPayrollPeriod  = null; 
	boolean bolPageBreak  = false;
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);   
	strTemp = WI.fillTextValue("sal_period_index");				
	for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			 strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) + "-" + (String)vSalaryPeriod.elementAt(i + 7);
			 break;
		}
	}		
	vRetResult = prConversion.operateOnDOELeaveConversion(dbOP,request, 4);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="8" align="center" class="thinborder"><strong>LIST OF EMPLOYEES WITH LEAVE CONVERSION FOR THE PERIOD <%=strPayrollPeriod%></strong></td>
    </tr>
    <tr>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td> 
      <td width="33%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">RATE</font></strong></td>
			<td width="11%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
			<td width="11%" align="center" class="thinborder"><strong><font size="1">EMPLOYMENT DATE </font></strong></td>
      <%
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = "DAYS CONVERTED";
			else
				strTemp = "DAYS TO CONVERT";
			%>			
      <td width="11%" align="center" class="thinborder"><strong><font size="1"><%=strTemp%></font></strong></td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>
    <tr>
		  <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%> </strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
					strTemp = " ";			
				}else{
					strTemp = " - ";
				}
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 10),"")%>&nbsp;</td>
<%
			strTemp = (String)vRetResult.elementAt(i + 10);
			strTemp = WI.getStrValue(strTemp,"0");
			dAmount = Double.parseDouble(strTemp);
			
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			dDays = Double.parseDouble(strTemp);
			
			dAmount = dAmount * dDays;
			if(dAmount == 0d)
				strTemp = "";
			else
				strTemp = CommonUtil.formatFloat(dAmount, 2);				
			%>		 
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
			<td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"&nbsp;")%>&nbsp;</td>
			<%
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td class="thinborder">			
			<div align="center"><strong> 
        <input name="conv_days_<%=iCount%>" type="text" size="5" maxlength="6"  class="textbox_noborder"
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right" readonly>
      </strong></div>			</td>
    </tr>
    <%} //end for loop%>
  </table>

  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>