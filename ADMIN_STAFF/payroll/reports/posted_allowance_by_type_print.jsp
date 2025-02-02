<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances,payroll.PReDTRME,java.util.Date" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
boolean bolHasTeam = false;
boolean bolRemoveOtherEarnings = true;
boolean bolPageBreak = false;

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Allowance Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;		
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"12")%>px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }
	TD.BOTTOM {
		border-bottom: solid 1px #000000;		
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
    }		
    TD.NoBorder {
		font-family:  Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
		}
		
	.others_header{
		border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("size_header"),"9")%>px;
	}	
	.others_body{		
    	border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.getStrValue(WI.fillTextValue("font_size"),"9")%>px;
	}
		
		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;	
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strHasWeekly = null;
	String strPayrollPeriod  = null;
	String strPeriodTo = null;
	String[] astrSalaryBase = {"Monthly rate", "Daily Rate", "Hourly Rate"};
	boolean bolProceed = true;
	int iSearchResult = 0;
	int i = 0;

	boolean bolShowALL = false;
	if(strUserId != null && (strUserId.equals("bricks") || strUserId.equals("SA-01")) )
		bolShowALL = true;	
	boolean bolShowBorder = false;
//add security here.

try
	{
		dbOP = new DBOperation(strUserId,
								"Admin/staff-Payroll-REPORTS-Payroll Register","posted_allowance.jsp");
								
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
														"posted_allowance.jsp");
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
	
	
		
	boolean bolOfficeTotal = false;
	boolean bolShowHeader = true; 
	String strCurAllowance = null;
	String strNextAllowance  = null;
	String strCurDept = null;
	String strNextDept = null;
	
	String strSchCode = dbOP.getSchoolIndex();
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	PRAllowances prAllowances = new PRAllowances();
	Vector vRetResult = null;	
	vRetResult = prAllowances.getAllAllowanceForPeriod(dbOP,request,2);
	if(vRetResult == null)
		strErrMsg = prAllowances.getErrMsg();
	else	
		iSearchResult = prAllowances.getSearchCount();
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post">
    
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
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			strPeriodTo = (String)vSalaryPeriod.elementAt(i + 7);
		}	  
		 }//end of for loop.%>	
	   
  
  <% if (vRetResult != null && vRetResult.size() > 0 ){
  		int iCtr = 1;
 		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
  		int iPage = 1; int iCount = 0;
		
		int iEmpCTR = 0;
		
		String strCurrentId = null;
		double dEmpTotal = 0d;
		double dGrandTotal = 0d;	
		double dTemp = 0d;	
		
		double dDeductedAmount = 0d;
		double dMonthlyAmount = 0d;
			
      for(i = 0; i < vRetResult.size(); ){	
		//dEmpTotal = 0d	;
		strCurrentId = "";
		iCount = 0;
		  %>  
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<%if( i > 0 ){%>
		<br /><br />
	<%}%>
  	<tr>      
      <td height="10" align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <br />
	  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
	   <br /> <br />
	  </td>
    </tr>
    <tr> 
      <td height="24" align="center">
	  	<%	strTemp = WI.fillTextValue("taxable_status"); 								
	 %>
	  	<div style="border:#000000 1px solid; width:450px;height:30px; padding:5px;" align="center">
		<%				
				if(strTemp.equals("1"))
					strTemp = "Taxable";
				else if(strTemp.equals("0"))
					strTemp = "Non - Taxable";
				else
					strTemp = "Taxable / Non -Taxable";	
		%>
		  	<strong><font>
				
			<%=strTemp%> Other Income Detail per Allowance Type <br />
		  	</font></strong><font size="1"> Pay Date : <%=WI.getStrValue(strPeriodTo,"")%></font>
		</div>
	  </td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
    <tr>
      <td colspan="7" class="BOTTOM"  align="right" height="30">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td width="8%" height="33" align="center" class="headerBOTTOMLEFT"><strong>EMP. ID # </strong></td>
	 <td width="24%" height="33"  align="center" class="headerBOTTOMLEFT"><strong>EMPLOYEE NAME</strong></td> 	
	 <td height="33" align="center" class="headerBOTTOMLEFT" colspan="2"><strong>COLLEGE / DEPARTMENT </strong></td>	
	 <td width="12%" height="33" align="center" class="headerBOTTOMLEFT"><strong>MONTHLY AMOUNT </strong></td>	
	 <td width="10%" height="33" align="center" class="headerBOTTOMLEFT"><strong>DEDUCTIONS </strong></td>	
	 <td width="10%" height="33" align="center" class="headerBOTTOMLEFTRIGHT" ><strong>AMOUNT</strong></td>	 
    </tr>
    <% 	
		dTemp = 0d;		
      for(; i < vRetResult.size(); ){
	  	 	dDeductedAmount = 0d;
			dMonthlyAmount = 0d;
	  		iCount+=1;
	  		strCurrentId = WI.getStrValue((String)vRetResult.elementAt(i),"");	
			
			if(bolShowHeader){
				bolShowHeader = false;
	 		 %>
			<tr>
			  <%
				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"");	  	
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"");//sub type
				if(strTemp2.length() > 0)
					strTemp = strTemp + " - " + strTemp2;
			 %>
			  <td height="30" colspan="54" valign="bottom" class='BOTTOM' >
			  	<strong><%=strTemp.toUpperCase()%></strong> 
				</td>
			</tr>
			<%}	
			
			if(i+15 < vRetResult.size()){
				if(i == 0)
					strCurAllowance = WI.getStrValue((String)vRetResult.elementAt(i+13),"0");				
			
				strNextAllowance = WI.getStrValue((String)vRetResult.elementAt(i + 27),"0");
					
				if(!(strCurAllowance).equals(strNextAllowance)){			
					bolOfficeTotal = true;					
					bolShowHeader = true;
				}	
			}	
	%>	
    <tr>
      <td  height="20" align="left" class="BOTTOMLEFT"><%=++iEmpCTR%>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i),"")%></td>
      <td  class="BOTTOMLEFT" align="left">&nbsp;<strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2),
							(String)vRetResult.elementAt(i+3), 4).toUpperCase()%></strong></td>
     <%
		
		strTemp = "";			
		strTemp2 = (String)vRetResult.elementAt(i+10);
		strTemp2 = WI.getStrValue(strTemp2," ","","");
		%>
	  <td align="left" class="BOTTOMLEFT" colspan="2">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+9),strTemp, strTemp2, strTemp2)).toUpperCase()%></td>
	  
      <%		
	   	dMonthlyAmount = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+8),"0"));	  
	  %>
      <td align="right" class="BOTTOMLEFT">&nbsp;<%=CommonUtil.formatFloat(dMonthlyAmount ,true)%>&nbsp;&nbsp;</td>
      <%		
	   	dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));	
		dMonthlyAmount =  Double.parseDouble((CommonUtil.formatFloat(dMonthlyAmount,true)).replaceAll(",","")) ;		
  	    dDeductedAmount =  dMonthlyAmount - Double.parseDouble((CommonUtil.formatFloat(dTemp,true)).replaceAll(",",""));   
		if(dDeductedAmount > 0)
			
	  %>
      <td align="right" class="BOTTOMLEFT">&nbsp;<%= (dDeductedAmount > 0)? "(" + CommonUtil.formatFloat(dDeductedAmount,true) + ")" : "0.00"%>&nbsp;&nbsp;</td>
      <%		
	   	//dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"));
	  	dEmpTotal += dTemp;
	  %>
      <td align="right" class="BOTTOMLEFTRIGHT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>
    </tr>
	
	 <%
	 	if(i+14 < vRetResult.size())
		 strCurAllowance = WI.getStrValue((String)vRetResult.elementAt(i+27),"0");	
	    
	 
	 %>
	
    <% if(bolOfficeTotal ||  (i+14) >= vRetResult.size() ){
	  	bolOfficeTotal = false; 
	  iCount+=1; %>
    <tr>
      <td colspan="6">&nbsp;</td>
      <td align="right" class="NoBorder" height="25"><strong> Total : &nbsp; &nbsp;<u><%=CommonUtil.formatFloat(dEmpTotal,true)%></u></strong>&nbsp;&nbsp;&nbsp;</td>
    </tr>
	<%
   
		//if( (i+14) < vRetResult.size() && !strCurrentId.equals(WI.getStrValue((String)vRetResult.elementAt(i+14),""))){
		 	dGrandTotal += dEmpTotal;
			dEmpTotal = 0d;	 
		//}
		
	 }//end total
	 
	  i = i + 14; 		
		 if(iCount >= iMaxRecPerPage || i >= vRetResult.size() ){
			if(iCount >= iMaxRecPerPage)
				bolPageBreak = true;
			break;
		}
		
		
	}//end of inner for loop 
	
	 
	 //if last page
	 if(i >= vRetResult.size()){ %>
		  <tr>
			  <td colspan="5">&nbsp;</td>
			  <td colspan="2" align="right" style="border-bottom:double #000000 3px" height="25"><strong>Grand Total : &nbsp; &nbsp;<%=CommonUtil.formatFloat(dGrandTotal,true)%></strong>&nbsp;</td>
    	</tr>
	<%} //end of last page %>
	
  </table>
	
	<% if(bolPageBreak){ bolPageBreak = false;%>
    	<div style="page-break-after:always">&nbsp;</div>    	
   	 <%}//if pagebreak;
	 
	}//end of outer for loop
	
	}//end of if vRetResult
	%>
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>