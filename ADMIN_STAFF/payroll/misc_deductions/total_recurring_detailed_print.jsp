<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
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
<title>Print Details of the recurring deduction</title>
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

	TD.thinborder {
		border-left: solid 1px #000000;
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Recurring Deductions","total_recurring_detailed.jsp");
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"total_recurring_detailed.jsp");
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
	Vector vSalaryPeriod = null;//detail of salary period.
	Vector vEmpDetail = null;
	PRMiscDeduction prMiscDed = new PRMiscDeduction(request);
	PReDTRME  prEdtrME = new PReDTRME();
	int iSearchResult = 0;
	int i = 0;
	int iMonth = 0;
	String strPayrollPeriod  = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	double dTemp = 0d;
	double dEmpTotal = 0d;
	int iIndexOf = 0;
	Integer iObjMonth = null;
	boolean bolPageBreak = false;
		
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", "July", 
												"August", "September", "October", "November", "December"};	
					
	double[] adDeptTotal = new double[25];
	double[] adGrandTotal = new double[25];
	
	String strCurColl = null;
	String strNextColl = null;

	String strCurDept = null;
	String strNextDept = null;
	boolean bolNextDept = true;
	boolean bolOfficeTotal = false;
	String strDeptName = null;
						
 	vRetResult = prMiscDed.getEmpDetailedRecurring(dbOP,request);
 	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
		if((vRetResult.size() % (15*iMaxRecPerPage)) > 0) ++iTotalPages;
		 for (;iNumRec < vRetResult.size();iPage++){// outermost for loop
 	%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td>
      <td width="6%" rowspan="2" align="center" class="thinborder"><font size="1">EMP ID </font></td> 
      <td width="18%" height="23" rowspan="2" align="center" class="thinborder"><font size="1">EMPLOYEE NAME </font></td>
      <%for(iMonth = 0;iMonth < astrMonth.length; iMonth++){%>
			<td colspan="2" align="center" class="thinborder"><%=astrMonth[iMonth]%></td>
			<%}%>
      <td width="7%" rowspan="2" align="center" class="thinborder"><strong><font size="1">TOTAL PAID</font></strong></td>
    </tr>
    <tr>
		<%for(iMonth = 0;iMonth < 12; iMonth++){%>
      <td align="center" class="thinborder">1st</td>
      <td align="center" class="thinborder">2nd</td>
		  <%}%>
    </tr>
    <% 
		for(; iNumRec < vRetResult.size();){ // DEPT FOR LOOP
		%>				
    <%if(bolNextDept){
			bolNextDept = false;
			for(iMonth = 0;iMonth < 25; iMonth++)
				adDeptTotal[iMonth] = 0d;
		%>
		<%if(bolIsSchool)
				strTemp = "College : ";
			else
				strTemp = "Division : ";
				
			strTemp2 = (String)vRetResult.elementAt(iNumRec+5);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
			strDeptName = (WI.getStrValue((String)vRetResult.elementAt(iNumRec+6),strTemp,strTemp2,strTemp2)).toUpperCase();
		%>				
		<tr>
      <td height="25" colspan="28" class="thinborder"><strong><%=strDeptName%></strong></td>
    </tr>
		<%}%>
		<% 
		for(; iNumRec<vRetResult.size();){
			i = iNumRec;
			if(i+16 < vRetResult.size()){
				if(i == 0){
					strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");		
					strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");	
				}
				strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + 15 + 7),"0");		
				strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + 15 + 8),"0");		
				
				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
					bolNextDept = true;
					bolOfficeTotal = true;
				} 
			}			
 		  vEmpDetail = (Vector)vRetResult.elementAt(i+12);
		  dEmpTotal = 0d;		
			iCount++;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
	  %>		 
    <tr>
      <td class="thinborder">&nbsp;<%=iIncr%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></td> 
			<%for(iMonth = 0;iMonth < 12; iMonth++){
				strTemp = null;
				iObjMonth = new Integer(iMonth + "0001");
 				iIndexOf = vEmpDetail.indexOf(iObjMonth);
				if(iIndexOf != -1){
					vEmpDetail.remove(iIndexOf);
					strTemp = (String)vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));  
					dEmpTotal += dTemp;
					adDeptTotal[iMonth*2] += dTemp;
					adGrandTotal[iMonth*2] += dTemp;					
				}else
					strTemp = "";
			%>
			<td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
			<%
				strTemp = null;
				iObjMonth = new Integer(iMonth + "0002");
				iIndexOf = vEmpDetail.indexOf(iObjMonth);
				if(iIndexOf != -1){
					vEmpDetail.remove(iIndexOf);
					strTemp = (String)vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));  
					dEmpTotal += dTemp;	
					adDeptTotal[iMonth*2 + 1] += dTemp;
					adGrandTotal[iMonth*2 + 1] += dTemp;				
				}else
					strTemp = "";			
			%>
			<td align="right" class="thinborder">&nbsp;&nbsp;<%=strTemp%>&nbsp;</td>
			<%}%>
			<%
					adDeptTotal[24] += dEmpTotal;
					adGrandTotal[24] += dEmpTotal;	
			%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dEmpTotal, true)%>&nbsp;</td>
		</tr>
		<% 
		 iNumRec+=15;
		 iIncr++;
		 if(iNumRec < vRetResult.size()){
			 strCurColl = WI.getStrValue((String)vRetResult.elementAt(iNumRec+7),"0");
			 strCurDept = WI.getStrValue((String)vRetResult.elementAt(iNumRec+8),"");
		 }	 
	
		if(bolNextDept){
			bolOfficeTotal = true;
			break;
		}
		%>		
    <%} //end employee for loop%>
	 <%  
		if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size())){
			bolOfficeTotal = false; 
		iCount++;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
		}
		else 
			bolPageBreak = false; 	
		%>			
    <tr>
      <td height="25" colspan="3" align="right" class="thinborder">DEPARTMENT TOTAL :</td>
      <%for(iMonth = 0;iMonth < 12; iMonth++){%>
			<%
				if(adDeptTotal[iMonth*2] > 0)
					strTemp = CommonUtil.formatFloat(adDeptTotal[iMonth*2], true);
				else
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				if(adDeptTotal[iMonth*2 + 1] > 0)
					strTemp = CommonUtil.formatFloat(adDeptTotal[iMonth*2 + 1], true);
				else
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adDeptTotal[24], true)%>&nbsp;</td>
    </tr>
		<%}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRows.size()))%>
		<%if(iNumRec >= vRetResult.size()){%>
		<tr>
      <td height="25" colspan="3" align="right" class="thinborder">GRAND TOTAL : </td>
      <%for(iMonth = 0;iMonth < 12; iMonth++){%>
			<%
				if(adGrandTotal[iMonth*2] > 0)
					strTemp = CommonUtil.formatFloat(adGrandTotal[iMonth*2], true);
				else
					strTemp = "";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				if(adGrandTotal[iMonth*2 + 1] > 0)
					strTemp = CommonUtil.formatFloat(adGrandTotal[iMonth*2 + 1], true);
				else
					strTemp = "";
			%>			
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adGrandTotal[24], true)%>&nbsp;</td>
    </tr> 	
		<%} // end if (bolPageBreak || iNumRec >= vRetResult.size())%>
			<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>			
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