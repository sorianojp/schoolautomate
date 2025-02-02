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
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null; 	
			
//add security here.

if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./loan_report_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Loan Payroll","loan_report.jsp");
								
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
	int i = 0;	
	Vector vRetResult = null;	
	vRetResult = PRetLoan.getLoanSummaryForPeriod(dbOP,WI.fillTextValue("sal_period_index"));
	if(vRetResult == null)
		strErrMsg = PRetLoan.getErrMsg();
	else		
		iSearchResult = PRetLoan.getSearchCount();		
	
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="loan_report.jsp">
<table  id="table1" width="100%"> 
<tr><td>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table2">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL : LOAN REPORT FOR PAYROLL ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table3">
    <tr>
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"><select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
        </select>
        -
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr>
      <td width="20%" height="25">&nbsp;</td>
      <td width="14%">Salary Period</td>
      <td width="66%" colspan="3"><strong>
        <label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
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
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
        </label>
        </strong>
          <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
          <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
          <font size="1">for weekly </font>
          <%}// check if the company has weekly salary type%>      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
	  %>
      <td height="26">Loan Code</td>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();" id="_P">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_code, loan_name ",
		                    " from ret_loan_code where is_valid = 1  " +
												" order by loan_code", strTemp ,false)%>
        </select>
      </strong></font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();"></td>
    </tr>
  </table></td>
</tr></table> 
<!-- end of table1 --> 
  
  </table>
	
	
<% 
if(vRetResult != null && vRetResult.size() > 1){%>
	<table width="40%" align="center">
		
	  <tr>
	  	<td valign="bottom">
		  <div align="right"><font size="2">Number of Employees / rows Per 
          Page :</font><font>
            <select name="num_rec_page">
              <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 15; i <=30 ; i++) {
				if ( i == iDefault) {%>
              <option selected value="<%=i%>"><%=i%></option>
              <%}else{%>
              <option value="<%=i%>"><%=i%></option>
              <%}}%>
            </select>			
            <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a></div>
      </div>
		</td>
	  </tr>
	   <tr> 
			  <td height="24" align="right"> <%
				int iPageCount = iSearchResult/PRetLoan.defSearchSize;				
				if(iSearchResult % PRetLoan.defSearchSize > 0) ++iPageCount;						
				if(iPageCount > 1)	
				{%> <div align="right">Jump To page: 
				  <select name="jumpto" onChange="SearchEmployee();">
					<%
					strTemp = request.getParameter("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
		
					for( i =1; i<= iPageCount; ++i )
					{
						if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
							}
					}
					%>
				  </select>		  
				  <%}%>
				</div>
		   </td>
	  </tr>
	  
  </table>
  
  <br />
   <table  bgcolor="#FFFFFF" width="40%" border="0" cellspacing="0" cellpadding="0" align="center">
  	<tr>
		<td width="4%" class="thinborderNONE" height="30">&nbsp;</td>
		<td width="54%" align="center" class="thinborderNONE"><strong>NAME</strong></td>
		<td width="42%" align="center" class="thinborderNONE"><strong>AMOUNT DEDUCTED</strong></td>
	</tr>
	
	<% int iCtr = 1;
		double dTemp = 0d;
	for(i = 0; i < vRetResult.size() ; i+=10){		
		if(i+10 < vRetResult.size()){							 
				strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+1),"0");		
				strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");				
				 
				strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + 11),"0");		
				strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + 12),"0");
				
				if( ( !(strCurColl).equals(strNextColl) )    ||  ( !(strCurDept).equals(strNextDept) &&  strCurColl.equals("0") )  )
					bolShowHeader = true;			 
				
		}
	  
	if(bolShowHeader){
		bolShowHeader = false;
	 %>			
		<tr>
			<td width="4%" class="thinborderNONE" height="30">&nbsp;</td>
			<td colspan="2" class="thinborderNONE" height="20" align="left" valign="bottom"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"","",(String)vRetResult.elementAt(i+7))%></strong></td>
		</tr>
	<%}//end of bolShowHeader%>	
		<tr>
			<td width="4%" class="thinborderNONE" height="20" align="right"><%=iCtr++%>&nbsp;</td>
			<td width="54%" align="left" class="thinborderNONE">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4)%></td>
			<%
				strTemp =WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
				dTemp  = Double.parseDouble(strTemp);
			%>				
			<td width="42%" align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
		</tr>	
	<%}%>
  </table>
  
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