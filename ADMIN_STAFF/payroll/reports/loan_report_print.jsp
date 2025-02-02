<%@ page language="java" import="utility.*,java.lang.Integer, java.util.Vector,payroll.PRRetirementLoan, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Loan Report for Payroll</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }
	TD.headerTOPBOTTOMLEFTRIGHT {
	    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }	
	TD.headerTOPBOTTOMRIGHT {
	    border-bottom: solid 1px #000000;		
		border-right: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }	
	 TD.headerTOPLEFTRIGHT {
   		 border-top: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }	
	 TD.headerTOPRIGHT {
    	border-top: solid 1px #000000;		
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }		
	 TD.headerTOPLEFT {   
		border-left: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 12px;
    }	

	TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 12px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	//
//	var strPrepared = document.form_.prepared_by.value;
//	var strReviewed = document.form_.reviewed_by.value;
//	
//	//check prepared by and verified by
//	if(strPrepared.length == 0){
//		alert("Please enter prepared by name.");
//		return;		
//	}
//	if(strReviewed.length == 0 ){
//		alert("Please enter verified by name.");
//		return;		
//	}
	
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
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
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
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
</script>

<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("SA-01")) )
		bolShowALL = true;	
	boolean bolShowBorder = false;
	boolean bolShowHeader = true;
	boolean bolSubIncluded = true;
	String strCurColl = null;
	String strPrevColl = "";
	String strCurDept = null;
	String strPrevDept = ""; 	
	String strNxtColl = "";
	String strNxtDept = "";
			
//add security here.

try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Loan Payroll","");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"loan_report.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();	
	
	PRRetirementLoan PRetLoan = new PRRetirementLoan(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;	
	String strSchCode = dbOP.getSchoolIndex();
	boolean bolPageBreak = false;
	int i = 0;	
	Vector vRetResult = null;	
	vRetResult = PRetLoan.getLoanSummaryForPeriod(dbOP,WI.fillTextValue("sal_period_index"));
	if(vRetResult == null)
		strErrMsg = PRetLoan.getErrMsg();
	else		
		iSearchResult = PRetLoan.getSearchCount();
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="loan_report.jsp">
 <%
 		String strPeriodTo = "";
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");	
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			strPeriodTo = (String)vSalaryPeriod.elementAt(i + 7);
		}	  
		 }//end of for loop.%>	
	
	
<% 
if(vRetResult != null && vRetResult.size() > 1){

	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	int iPage = 1; int iCount = 0;
	int iCtr = 1;
	double dTemp = 0d;
	double dDeptTotal = 0d;
	double dGrandTotal = 0d;
	for(i = 0; i < vRetResult.size();  i+=10){	
		bolSubIncluded = false;
		if(i == 0){ //print header on first page only. ingon si gretchen..sul03152013

%>
	<table width="100%" align="center">	
	  <tr>
	  	<td align="center">		  	
			<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> <br /></strong>
			<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>	<br />			 		
		 </td>
	  </tr>
	  <tr>
	  	<td align="center" height="30">
			<strong>				
				<font size="3"><%=WI.getStrValue((String)vRetResult.elementAt(9),"")%></font>
			</strong></td>
	  </tr>
	   <tr>
	  	<td align="center" height="30" valign="top"><%=WI.getStrValue(strPayrollPeriod,"")%></td>
	  </tr>
  </table>
  <br />
  <%}//end of print header%>
   <table  bgcolor="#FFFFFF" width="60%" border="0" cellspacing="0" cellpadding="0" align="center">
  	<tr>
		<td width="4%" class="thinborderNONE" height="30">&nbsp;</td>
		<td width="54%" align="center" class="thinborderNONE"><strong>NAME</strong></td>
		<td width="42%" align="center" class="thinborderNONE"><strong>AMOUNT DEDUCTED</strong></td>
	</tr>
	
	<% 
	iCount = 0;
	for(; i < vRetResult.size() ; i+=10){	
		iCount+=1;	
		if(i+10 < vRetResult.size()){							 
				strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+1),"0");		
				strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");							
				
				strNxtColl = WI.getStrValue((String)vRetResult.elementAt(i+11),"0");		
				strNxtDept = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");	
				
				if( ( !(strCurColl).equals(strPrevColl) )    ||  ( !(strCurDept).equals(strPrevDept) &&  strCurColl.equals("0") )  )
					bolShowHeader = true;			 
				
		}	  
	if(bolShowHeader ){
		bolShowHeader = false;	%>
				
		<tr>
			<td width="4%" class="thinborderNONE" height="30">&nbsp;</td>
			<td colspan="2" class="thinborderNONE" height="20" align="left" valign="bottom"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"","",(String)vRetResult.elementAt(i+7))%></strong></td>
		</tr>
	<%	
		}//end of bolShowHeader%>	
		<tr>
			<td width="4%" class="thinborderNONE" height="20" align="right"><%=iCtr++%>&nbsp;</td>
			<td width="54%" align="left" class="thinborderNONE">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4)%></td>
			<%
				strTemp =WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
				dTemp  = Double.parseDouble(strTemp);
				dDeptTotal += dTemp;
			%>				
			<td width="42%" align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
		</tr>			
	<%		
		strPrevColl = strCurColl;
		strPrevDept = strCurDept;
		
		if( ( !(strCurColl).equals(strNxtColl) )    ||  ( !(strCurDept).equals(strNxtDept) &&  strCurColl.equals("0") )  || i+10 >= vRetResult.size() ){
			bolSubIncluded = true;
		%>
			<tr>
			  <td>&nbsp;</td>
			  <td colspan="2" align="right" class="NoBorder" height="25"><strong>Subtotal : &nbsp; &nbsp;<%=CommonUtil.formatFloat(dDeptTotal,true)%>&nbsp;</strong></td>			</tr>
		<% dGrandTotal += dDeptTotal;
		dDeptTotal = 0d;}//end of subtotal	
	
	
		if(iCount >= iMaxRecPerPage || i >= vRetResult.size() ){
			bolSubIncluded = true;
			if(iCount >= iMaxRecPerPage)
				bolPageBreak = true;
			break;
		}	
	
	}//end of inner for loop
	
	 //if last page
	 if(i >= vRetResult.size()){ %>
		  <tr>
			  <td>&nbsp;</td>
			  <td colspan="2" align="right"  height="25"><strong>Grand Total : &nbsp;<u> &nbsp;<%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</u></strong></td>
    	</tr>
	<%} //end of last page 	
	%>
  </table>
  
  <% if(bolPageBreak){
  	bolPageBreak = false;%>
    	<div style="page-break-after:always">&nbsp;</div>    	
   	 <%}//if pagebreak;
	 
  }//end of outer for loop%>
  
<%} //end of  if vRetResult not null%>
	
 
	
    <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="view_all" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>