<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances, payroll.PayrollConfig" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.noBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.smallFont{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.smallFontTop{
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee(){
	if(document.form_.cola_ecola_index.selectedIndex == -1){
		this.SubmitOnce("form_");
		return;
	}
	document.form_.allowance_name.value = document.form_.cola_ecola_index[document.form_.cola_ecola_index.selectedIndex].text;
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value="";
 	//document.form_.submit();
	this.SubmitOnce("form_");
}

function ReloadPage(){	
	//document.form_.page_reloaded.value = "1";
	//document.form_.searchEmployee_.value="";
	//document.form_.print_page.value="";	
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee_.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./employee_allowances.jsp";
}

function PrintPg(){
	document.form_.print_page.value="1";
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

function CopyRate(strBase){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		if(strBase == '0'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.monthly_'+i+'.value=document.form_.monthly_1.value');			
		}else if(strBase == '1'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.daily_'+i+'.value=document.form_.daily_1.value');					
		}else{
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.hourly_'+i+'.value=document.form_.hourly_1.value');		
		}
}
-->
</script>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Variable Allowance-Variable Allowance Management","employee_allowances.jsp");
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

//end of authenticaion code.
	Vector vRetResult = null;
	Vector vAllowanceInfo = null;
	
	PRAllowances prAllow = new PRAllowances();
 	
 	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	String strEmpCatg = null;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time","Contractual",""}; 
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname",strTemp2,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	
	String[] astrBasis={"Fixed Allowance","Present","Absences", "Hours Present"};

	String[] astrActualName ={"Every Salary Period","Monthly (Every Last Period of the Month)", 
												"Quarterly (Every Last Period of the Quarter)",
												"Bi-annual (June &amp; December)","Monthly (Every First Period)"};
	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	boolean bolFixed = false;
	Vector vEmpAllowance = null;
	double dTemp = 0d;
	String strLine = null;
	int j = 0;
	boolean bolPageBreak = false;

		vRetResult = prAllow.getAppliedAllowanceToEmp(dbOP,request);
	if (vRetResult != null) {	
 		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<body onLoad="javascript:window.print();">
<form name="form_">
   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">

    <tr> 
      <td height="25" colspan="4" align="center" class="thinborderBOTTOM"><strong> EMPLOYEE ALLOWANCES </strong></td>
    </tr>
    <tr> 
      <td width="4%" height="24" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="11%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="25%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="60%" align="center" class="thinborderBOTTOMRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="34%" class="noBorder"><strong>ALLOWANCE NAME </strong></td>
          <td width="13%" class="noBorder"><strong>MONTHLY</strong></td>
          <td width="12%" class="noBorder"><strong>DAILY</strong></td>
          <td width="12%" class="noBorder"><strong>HOURLY</strong></td>
          <td width="29%" class="noBorder"><strong>EFFECTIVE DATE </strong></td>
        </tr>
      </table></td>
    </tr>
    <% 
		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
			vEmpAllowance = (Vector)vRetResult.elementAt(i+11); 			
		%>
    <tr> 
      <td height="25" align="center" class="thinborderBOTTOMLEFTRIGHT"><span class="thinborderTOPLEFT"><%=iIncr%></span></td>
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></span></td>
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>       						
			<td class="thinborderBOTTOMRIGHT">
			<%if(vEmpAllowance != null && vEmpAllowance.size() > 0){%>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%for(j = 0;j < vEmpAllowance.size(); j+= 22){%>
				<tr>
					<% 
						if(j == 0)
							strLine = "smallFont";
						else
							strLine = "smallFontTop";
					%>
          <td width="34%" class="<%=strLine%>" height="12">&nbsp;<%=(String)vEmpAllowance.elementAt(j+3)%> <%=WI.getStrValue((String)vEmpAllowance.elementAt(j+4), "(",")","")%></td>
					<% strTemp = (String)vEmpAllowance.elementAt(j+7); 
						dTemp = Double.parseDouble(strTemp);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						if(dTemp == 0d)
							strTemp = "--";			
					%>
          <td width="12%" class="<%=strLine%>">&nbsp;<%=strTemp%></td>
					<% strTemp = (String)vEmpAllowance.elementAt(j+8); 
						dTemp = Double.parseDouble(strTemp);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						
						if(dTemp == 0d)
							strTemp = "&nbsp;";			
						%>
          <td width="11%" class="<%=strLine%>">&nbsp;<%=strTemp%></td>
					<% strTemp = (String)vEmpAllowance.elementAt(j+9); 
						dTemp = Double.parseDouble(strTemp);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						
						if(dTemp == 0d)
							strTemp = "&nbsp;";			
					%>
          <td width="11%" class="<%=strLine%>">&nbsp;<%=strTemp%></td>
					<%
						strTemp = (String)vEmpAllowance.elementAt(j+5); 
						if(strTemp != null){
							strTemp += WI.getStrValue((String)vEmpAllowance.elementAt(j+6), "-", "","");
						}
						strTemp = WI.getStrValue(strTemp);
					%>
          <td width="32%" class="<%=strLine%>">&nbsp;<%=strTemp%></td>
        </tr>
				<%}%>
      </table>
			<%}%>			</td>
		</tr>
    <%}// end for loop%>
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