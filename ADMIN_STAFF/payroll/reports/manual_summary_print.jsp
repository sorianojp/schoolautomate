<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME, payroll.OvertimeMgmt" %>
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
<title>Manual Encoding Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
//	this.SubmitOnce('form_');
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
			eval('document.form_.adj_amount_'+i+'.value=document.form_.adj_amount_1.value');			
	}
}
function CopyDuration(){
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
			eval('document.form_.worked_dur_'+i+'.value=document.form_.worked_dur_1.value');			
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
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
	String strHasWeekly = null;
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	boolean bolIsGovernment = false;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Manual Adjustment","manual_summary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");	
		
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");		
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");		
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
														"manual_summary.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	int iSearchResult = 0;
	int i = 0;
	int iCtr = 0;
	int iOT = 0;
	int iIndex = 0;
	int iHour = 0;
	int iMinute = 0 ;
	
	String strValue = null;
	double dTemp = 0d;
	String strPayrollPeriod  = null;	 
	boolean bolPageBreak = true;
	
	Vector vEmpWorked = null;
	Vector vEmpAllowance = null;
	Vector vEmpAdjustment = null;
	Vector vEmpAbsence = null;
	Vector vEmpLateUt = null;
	Vector vEmpTaxOverride = null;
	Vector vFixedCon = null;
	Vector vEmpRate = null;
	Vector vEmpOT  = null;

	Vector vOTTypes = null;
	if(WI.fillTextValue("hide_overtime").equals("1"))
		vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
	else
		vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
	
	Vector vAdjTypes = null;
	if(WI.fillTextValue("hide_adjustment").equals("1"))
		vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
	else
		vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
		vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	strTemp = WI.fillTextValue("sal_period_index");		
	for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 1) + "-" + (String)vSalaryPeriod.elementAt(i + 2);
				break;
		}
	}


	vRetResult = prEdtrME.getManualEncodingSummary(dbOP,request);
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()/(35*iMaxRecPerPage));	
	if((vRetResult.size() % (35*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
<body onLoad="javascript:window.print();">
<form name="form_">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20" colspan="10" align="center"><strong>EMPLOYEE MANUALLY ENCODED VALUES FOR PERIOD : <%=strPayrollPeriod%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	   <tr>
      <td width="2%" class="thinborder">&nbsp;</td>
      <td width="4%" class="thinborder">&nbsp;</td> 
      <td width="24%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">BASIC RATE </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">WORK DURATION</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">LATE / UNDERTIME </font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">ABSENCES</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">TAX</font></strong></td>
       <%
 			if(vOTTypes != null && vOTTypes.size() > 0){
			for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
				strTemp = (String)vOTTypes.elementAt(iOT+1);
				//if(!strSchCode.startsWith("TAMIYA"))
				//	strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
			<td width="5%" align="center" class="thinborder"><%=strTemp%></td>      
      <%}
			}%>
			<%
 			if(vAdjTypes != null && vAdjTypes.size() > 0){
			for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){

				strTemp = (String)vAdjTypes.elementAt(iOT+1);
				//if(!strSchCode.startsWith("TAMIYA"))
				//	strTemp += "<br>"+ CommonUtil.formatFloat((String)vAdjTypes.elementAt(iOT+3),false);
			%>
			<td width="5%" align="center" class="thinborder"><%=strTemp%>*</td>            
      <%}
			}%>
			<td width="5%" align="center" class="thinborder"><strong><font size="1">SSS</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">PHIC</font></strong></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">PAG-IBIG</font></strong></td>
      <%if(bolIsGovernment){%>
			<td width="5%" align="center" class="thinborder"><strong><font size="1">GSIS</font></strong></td>
			<%}%>
			<%if(bolIsSchool){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">PERAA</font></strong></td>
			<%}%>
    </tr>
    <%
		 for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=35,++iIncr, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;		
					
		 	vEmpAdjustment = (Vector)vRetResult.elementAt(i+8);
			vEmpAbsence = (Vector)vRetResult.elementAt(i+9);
			vEmpLateUt = (Vector)vRetResult.elementAt(i+10);
			vEmpTaxOverride = (Vector)vRetResult.elementAt(i+11);
			vFixedCon =  (Vector)vRetResult.elementAt(i+12);
			vEmpWorked = (Vector)vRetResult.elementAt(i+13);
			vEmpRate  = (Vector)vRetResult.elementAt(i+14);
			vEmpOT  = (Vector)vRetResult.elementAt(i+15);
			//vFixedCon = null;
			//vEmpWorked = null;
			vEmpAllowance = null;
			//vEmpAdjustment = null;			
			//vEmpLateUt = null;
	  %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<%
				strTemp = "&nbsp;";
 				if(vEmpRate != null && vEmpRate.size() > 0){					
					strTemp	 = (String)vEmpRate.elementAt(0);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					if(dTemp == 0d){
						strTemp	 = (String)vEmpRate.elementAt(1);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
						if(dTemp == 0d){					
							strTemp = "&nbsp;";
						}
					}
 				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <%
				strValue = "";
				strTemp2 = "";
 				if(vEmpWorked != null && vEmpWorked.size() > 0){					
					for(iCtr = 0;iCtr < vEmpWorked.size(); iCtr += 8){						
						strTemp2 = WI.getStrValue((String)vEmpWorked.elementAt(iCtr+2));
						if(strTemp2.equals("1")){
							// days
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " day(s)";
						} else if(strTemp2.equals("2")){
							// hours
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)";
						} else if(strTemp2.equals("3")){
						  // faculty hours
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)(fac)";
						} else if(strTemp2.equals("4")){
						  // overload							
							strTemp2 = (String)vEmpWorked.elementAt(iCtr+1) + " hour(s)(OL)";
						}

						if(strValue.length() == 0)
							strValue = strTemp2;
						else
							strValue += "<br>" + strTemp2;
					}
				}
			%>
		  <td align="right" class="thinborder">&nbsp;<font size="1"><%=WI.getStrValue(strValue)%></font></td>
			<%
				strValue = "";
				strTemp2 = "";
				strTemp = null;
  				if(vEmpLateUt != null && vEmpLateUt.size() > 0){					
					for(iCtr = 0;iCtr < vEmpLateUt.size(); iCtr += 10){						
						strTemp	 = (String)vEmpLateUt.elementAt(iCtr+1);
						strTemp = CommonUtil.formatFloat(strTemp, true);
						dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
						if(dTemp == 0d)						
							strTemp = "";
						strTemp2 = WI.getStrValue((String)vEmpLateUt.elementAt(iCtr+4));
						if(strTemp2.equals("1")){
							// UNDERTIME
							strTemp2 = WI.getStrValue(strTemp, "UT : ","","");
						} else {
							// LATE
							strTemp2 = WI.getStrValue(strTemp, "Late : ","","");
						} 
						
						if(strValue.length() == 0)
							strValue = strTemp2;
						else
							strValue += "<br>" + strTemp2;
					}
				}
			%>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue(strValue,"&nbsp;")%></font></td>
			<%
				strTemp = "&nbsp;";
 				if(vEmpAbsence != null && vEmpAbsence.size() > 0){					
					strTemp	 = (String)vEmpAbsence.elementAt(1);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					if(dTemp == 0d)						
						strTemp = "";
 				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		  <%
			strValue = "--";
			strTemp = "";
 			if(vEmpTaxOverride != null && vEmpTaxOverride.size() > 0){					
				strTemp = (String)vEmpTaxOverride.elementAt(1);
				strValue = (String)vEmpTaxOverride.elementAt(0);
				if(strTemp.equals("1"))
					strValue = CommonUtil.formatFloat(strValue, true);
				else
					strValue = CommonUtil.formatFloat(strValue, false) + "%";
			}
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strValue, "&nbsp;")%></td>
			<%
			if(vOTTypes != null && vOTTypes.size() > 0){
			 for(iOT = 0;iOT < vOTTypes.size(); iOT+=19){
			 		
				 strTemp = null;
				 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
				 if(iIndex != -1){
				 		if(WI.fillTextValue("show_ot_time").length() > 0){
							strTemp = WI.getStrValue((String)vEmpOT.elementAt(iIndex+2), "0");
							dTemp = Double.parseDouble(strTemp);
							iHour = (int)dTemp/60;
							iMinute = (int)(dTemp - (iHour*60));
							if(iHour > 0 || iMinute > 0)
								strTemp = iHour + ":" + iMinute;
							else
								strTemp = "&nbsp;";
							
					 	}else{
							strTemp = (String)vEmpOT.elementAt(iIndex+1);					 
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
							//dLineTotal += dTemp;
							strTemp = CommonUtil.formatFloat(dTemp,true);
							if(dTemp == 0d)
								strTemp = "&nbsp;";							
						}
				 } 
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>      
      <%}
			}%>	
			<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0;iOT < vAdjTypes.size(); iOT+=19){
				 dTemp = 0d;
				 strTemp = null;
				 iIndex = vEmpAdjustment.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
						if(WI.fillTextValue("show_adj_duration").length() > 0){
							strTemp = WI.getStrValue((String)vEmpAdjustment.elementAt(iIndex+3), "0");
							dTemp = Double.parseDouble(strTemp);
					 	}else{
							strTemp = (String)vEmpAdjustment.elementAt(iIndex+2);					 
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
							//dLineTotal += dTemp;
						}
					}

				strTemp = CommonUtil.formatFloat(dTemp, true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";	
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>            
      <%}
			}%>	
			<%
				// d_type
				// 0 = sss_amt
				// 1 = pag_ibig
				// 2 = philhealth_amt
				// 3 = peraa
				// 4 = gsis_ps
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(0));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>
			<td align="right" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp, "&nbsp;")%>&nbsp;</td>
			<%
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(2));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(1));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			
			<%
				if(bolIsGovernment){
 				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(4));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}%>
			<%if(bolIsSchool){
				strTemp = null;
				if(vFixedCon != null && vFixedCon.size() > 0){
					iIndex = vFixedCon.indexOf(new Integer(3));
					if(iIndex != -1){
						strTemp = (String)vFixedCon.elementAt(iIndex+2);
					}					
				}
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}%>
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