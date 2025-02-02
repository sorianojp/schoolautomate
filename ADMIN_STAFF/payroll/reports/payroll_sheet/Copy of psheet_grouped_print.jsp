<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, 
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;

WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
	}	
	
	TD.headerWithBorderRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
	TD.headerWithBorder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
	
  TD.header {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }

  TD.headerNoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("size_header")%>.px;
  }
		
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
 		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","psheet_grouped.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");		
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
														"psheet_grouped.jsp");
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
	
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;	
 	String strSchCode = dbOP.getSchoolIndex();
 	
	int iFieldCount = 75;// number of fields in the vector..
	int iNumRec = 0; 
	
	double dTemp = 0d;
 	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	boolean bolMoveNextPage = false;
	int i = 0;
	int iIndex = 0;	  
	Vector vRetResult = null;
	int iIncr = 1;
	boolean bolShowBorder = (WI.fillTextValue("show_border")).length() > 0;
	String strBorder = "";
	String strBorderRight = "";
	
	boolean bolNextDept = true;
 	
	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
 	 
	double dDeptGross = 0d;
 
		
	boolean bolOfficeTotal = false;
 	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	  if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		break;
	  }
	}
	// System.out.println("--------------------------------------");
	if (vRetResult != null) {	
	int iPage = 1; 
	int iCount = 0;
	int iDeptCount = 0; 
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		
	if(vRetResult != null){
	int iTotalPages = (vRetResult.size())/(iFieldCount*iMaxRecPerPage);	
 
	if((vRetResult.size() % (iFieldCount * iMaxRecPerPage)) > 0)
		 ++iTotalPages;

	 for (;iNumRec < vRetResult.size();iPage++){ // OUTERMOST FOR LOOP
	 	dTemp = 0d;
		dLineTotal = 0d;

		 
%>
<body onLoad="javascript:window.print();"> 
<form name="form_" 	method="post" action="psheet_grouped.jsp">
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" align="center" class="thinborderBOTTOM"><strong><%=WI.fillTextValue("report_title")%> FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
    </tr>
	</table>
		<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="13%" align="center" <%=strBorderRight%>>ID</td>
      <td width="13%" height="33" align="center" <%=strBorderRight%>>NAME 
          OF EMPLOYEE </td>
 
    </tr>
    <% 
		for(; iNumRec < vRetResult.size();){ // DEPT FOR LOOP
		%>
    <%
 		if(bolNextDept || bolMoveNextPage){
			if(bolNextDept){
				// after adding to the grand total... zero out the department totals
				dDeptBasic = 0d;
				dDeptGross = 0d;
			}		
		
	  bolNextDept = false;	
		
		if(iDeptCount == 3){
			iDeptCount = 0;
			iCount++;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				bolMoveNextPage = true;
				continue;
			}
			else 
				bolPageBreak = false;			
		}else
			iDeptCount++;
    %>
		
		<%if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRetResult.elementAt(iNumRec+63);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
		%>		
    <tr>
      <%				
				if(bolShowBorder)
					strBorderRight = "class='thinborderBOTTOMLEFTRIGHT'";
				else
					strBorderRight = "class='NoBorder'";
			%>		
      <td height="19" colspan="28" valign="bottom" <%=strBorderRight%>><strong><%=(WI.getStrValue((String)vRetResult.elementAt(iNumRec+62),strTemp,strTemp2,strTemp2)).toUpperCase()%></strong></td>
    </tr>
		<%}// bolNextDept || bolMoveNextPage)%>
 
  <%for(; iNumRec < vRetResult.size();){// employee for loop
	i = iNumRec;
	if(i+iFieldCount+1 < vRetResult.size()){
 		if(i == 0){
			strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");		
			strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+3),"");	
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 2),"0");		
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 3),"");		
			
 		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
 			bolNextDept = true;
			bolOfficeTotal = true;
 		}
	}

	dLineTotal = 0d;
	iCount++;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
 		break;
	}
	else 
		bolPageBreak = false; 
 		%>	
    <tr>
      <%
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
			%>		

      <%if(WI.fillTextValue("show_emp_id").length() > 0){
				strTemp = (String)vRetResult.elementAt(i + 60);
			%>	
			<td valign="bottom" <%=strBorder%>><%=WI.getStrValue(strTemp)%></td> 
			<%}%>
      <td height="22" valign="bottom" <%=strBorder%>><strong><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6), 4)%></strong></td> 
 
      </tr>
  <% 
 	 iNumRec+=iFieldCount;
	 iIncr++;
	 if(iNumRec < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(iNumRec+2),"0");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(iNumRec+3),"");
	 }	 

 	if(bolNextDept){
		bolOfficeTotal = true;
		break;
	}

  %>
     <%}//end employee for loop%>  
		 
  <%  
  if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size())){
  	bolOfficeTotal = false;
	iCount++;

	if (iCount > iMaxRecPerPage)
		bolPageBreak = true;
	else
		bolPageBreak = false;
  %>	    
		<tr>
      <%
				if(bolShowBorder)
					strBorder =  "class='thinborder'";
				else
					strBorder = "class='NoBorder'";
			%>
      <td height="22" colspan="<%=iDeptCol%>" valign="bottom" <%=strBorder%>>Dept Total </td>
      <td align="right" valign="bottom" <%=strBorder%>>&nbsp;</td>
      </tr>
    <% 
		}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size()))
		%>
	<%if(iNumRec >= vRetResult.size()){%>		
    <tr>
      <td height="30" colspan="<%=iDeptCol%>" valign="bottom" <%=strBorder%>>Grand Total </td>
      <td align="right" valign="bottom" <%=strBorder%>><%=CommonUtil.formatFloat(dGrandAbsence,true)%></td>
      </tr>
	<%}/// bolPageBreak || iNumRec >= vRetResult.size()%>
	<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>		
  </table>  

  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
  <%}//page break ony if it is not last page.
   } //end for (iNumRec < vRetResult.size() // END OUTERMOST FOR LOOP
  }// end if vRetResult != null;
 } //end end upper most if (vRetResult !=null)%>  
	<input type="hidden" name="is_grouped" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>