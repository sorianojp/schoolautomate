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
	System.out.println("999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999");
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
		
	String strSchCode = dbOP.getSchoolIndex();
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	PRAllowances prAllowances = new PRAllowances();
	Vector vAllowanceList = null;	
	Vector vDepartmentList = null;	
	Vector vTemp = null;
	Vector vRetResult = null;	
	vRetResult = prAllowances.getAllAllowanceForPeriod(dbOP,request,3);
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
  		vAllowanceList = (Vector) vRetResult.elementAt(0);//allowance names	
		vDepartmentList = (Vector) vRetResult.elementAt(1);	
  
  		int iCtr = 1;
 		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
  		int iPage = 1; 
		int iCount = 0;		
		int iAllowanceCount = vAllowanceList.size()/3;
			
		double []arrDAllownceTotal = new double [iAllowanceCount];
		double dTemp = 0d;			
		double dTotalBasic = 0d;		
		double dNetPayTotal = 0d;
		double dOvertimeTtaol = 0d;
      for(i = 0; i < vDepartmentList.size(); ){
		iCount = 0;
		  %>  
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">  	
  	<tr>      
      <td height="10" align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <br />
	  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
	   <br />
	  </td>
    </tr>  
	 <tr> 
      <td height="40" colspan="54" align="center"><strong><font>EMPLOYEE ALLOWANCES : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td> <br />
    </tr>
  </table>
  
  <table width="100%">
  	 <tr>
      <td align="right" height="30" >Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="TOPRIGHT">   
     <tr>      
     <td width="26%" height="33" align="center" class="headerBOTTOMLEFT"><strong>DEPARTMENT </strong></td>
	 <td width="13%" height="33" align="center" class="headerBOTTOMLEFT"><strong>BASIC PAY </strong></td> 
	 <td width="11%" height="33"  align="center" class="headerBOTTOMLEFT"><strong>OVERTIME</strong></td> 
	 <% for(int j = 0; j < vAllowanceList.size(); j += 3){ %>
		 <td width="11%" height="33"  align="center" class="headerBOTTOMLEFT">&nbsp;<strong><%=WI.getStrValue((String)vAllowanceList.elementAt(j+2),"")%></strong></td> 
	 <%}%>	
   </tr>
    <% 	
		dTemp = 0d;	
      for(; i < vDepartmentList.size(); ){
	  		if( vDepartmentList.elementAt(i) == null )	
				strTemp = "";
			else
				strTemp = (String)vDepartmentList.elementAt(i);						
			strTemp2 = (String)vDepartmentList.elementAt(i+1);
			strTemp2 = WI.getStrValue(strTemp2," ","","");	
	%>	
 	 <tr>
		  <td  height="20" align="left" class="BOTTOMLEFT">&nbsp;<strong><%=(WI.getStrValue(strTemp,"", strTemp2, strTemp2)).toUpperCase()%></strong> </td>	
		 <!-- baic pay --> 
		 <% 
		 dTemp =  Double.parseDouble( WI.getStrValue((String)vDepartmentList.elementAt(i+2),"0") ); 
		 dTotalBasic +=  dTemp; %>
	  	 <!--
		 <td  height="20" align="left" class="BOTTOMLEFT">&nbsp; <%=CommonUtil.formatFloat(dTemp,true) %></td>
		 -->
		  <%		
			dTemp = Double.parseDouble( WI.getStrValue(vDepartmentList.elementAt(i+4)+"","0") ); 
			dNetPayTotal += dTemp;
		%>
		<td align="right" class="BOTTOMLEFT">&nbsp;<%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;&nbsp;</td>
		<%		
			dTemp = Double.parseDouble( WI.getStrValue(vDepartmentList.elementAt(i+5)+"","0") ); 
			dOvertimeTtaol += dTemp;
		%>
		<td  height="20" align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true) %>&nbsp; </td>
		 <% 
		 vTemp = new Vector();
		 vTemp = (Vector) vDepartmentList.elementAt(i+3);
		 for(int j = 0; j < vTemp.size(); j++){
		 	dTemp =  Double.parseDouble( WI.getStrValue((String)vTemp.elementAt(j),"0") ); 
		 	arrDAllownceTotal[j] += dTemp;
		  %>
		 	<td  height="20" align="left" class="BOTTOMLEFT">&nbsp; <%=((dTemp > 0)? CommonUtil.formatFloat(dTemp,true) : "") %></td>	
		 <%}%>	
		</tr>
	 
	 <% 
	  	iCount += 1;
	  	i += 6 ; 		
		 if(iCount >= iMaxRecPerPage || i >= vDepartmentList.size() ){
			if(iCount >= iMaxRecPerPage)
				bolPageBreak = true;
			break;
		}
		
	}//end of inner for loop 
	
	 
	 //if last page
	 if(i >= vDepartmentList.size()){ %>
		 <tr>
			 <td  height="30" align="right" class="BOTTOMLEFT">&nbsp;<strong> TOTAL &nbsp;&nbsp; </strong> </td>	
			  <td align="right" class="BOTTOMLEFT" height="25"><strong><%=CommonUtil.formatFloat(dNetPayTotal,true)%>&nbsp;&nbsp;</strong></td>
				<td  height="20" align="right" class="BOTTOMLEFT"><strong> <%=CommonUtil.formatFloat(dOvertimeTtaol,true) %></strong>&nbsp; </td>	
			  <%for(int j = 0; j < iAllowanceCount; j++){%>
			  	  <td  height="20" align="left" class="BOTTOMLEFT">&nbsp;<strong> <%=CommonUtil.formatFloat(arrDAllownceTotal[j],true) %></strong> </td>	
			  <%}%>
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