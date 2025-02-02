<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Additional Month Pay Details</title>
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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PRAddlPay" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Bonus Checker","bonus_details.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"bonus_details.jsp");
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

PRAddlPay prAddl = new PRAddlPay();
Vector vRetResult = null;
Vector vSalDetails = null;
Vector vPrevSal = null;
String strSchCode = dbOP.getSchoolIndex();
int iMonth = 0;
boolean bolPageBreak = false;
String[] astrMonth = {"January","February","March","April","May","June","July",
					"August", "September","October","November","December"};
int iIndexOf = 0;
Integer iObjMonth = null;
String strSalaryType = WI.fillTextValue("salary_type");
boolean bolNextDept = true;
boolean bolMoveNextPage = true;
double dTemp = 0d;
double dLineTotal = 0d;
double dDeptGross  = 0d;
int iDeptCount  = 0;
String strTemp2  = null;
int iFieldCount = 15;
String strCurColl = null;
String strCurDept = null;
String strNextColl = null;
String strNextDept = null;
boolean bolOfficeTotal = false;
double[] adDeptMonthly = new double[12];
double[] adGrandMonthly = new double[12];
double dDeptTotalAdjust = 0d;
double dDeptTotalBonus = 0d;
double dTotal = 0d;
	vRetResult = prAddl.getBonusDetails(dbOP,request);
	if (vRetResult != null) {
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(iFieldCount*iMaxRecPerPage);
	if(vRetResult.size() % (iFieldCount*iMaxRecPerPage) > 0) ++iTotalPages;
  for (;iNumRec < vRetResult.size();iPage++){
 		dLineTotal = 0d;
%>
<body onLoad="javscript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font>
      </td>
    </tr>
</table>

   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr class="thinborder">
      <td width="14%" align="center" class="thinborder"><strong>EMP ID</strong></td>
      <td width="35%" height="25" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <%for(iMonth = 0;iMonth < 12; iMonth++){%>
			<td class="thinborder" align="center"><%=astrMonth[iMonth]%></td>
			<%}%>
			<td class="thinborder" width="13%" align="center">Adjustment</td>
      <td class="thinborder" width="13%" align="center"><strong><%=WI.fillTextValue("bonus_name")%></strong></td>
      <%if(WI.fillTextValue("show_signature").length() > 0){%>
			<td class="thinborder" width="13%" align="center">Signature</td>
			<%}%>
    </tr>
    <%
		for(; iNumRec < vRetResult.size();){ // DEPT FOR LOOP
		%>
		<%
 		if((bolNextDept || bolMoveNextPage) && iCount != 20){
			if(bolNextDept){
				// after adding to the grand total... zero out the department totals
				dDeptGross = 0d;
				for(iMonth = 0;iMonth < 12; iMonth++)
					adDeptMonthly[iMonth] = 0d;
				dDeptTotalAdjust = 0d;
				dDeptTotalBonus = 0d;
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

			strTemp2 = (String)vRetResult.elementAt(iNumRec+6);
			strTemp2 = WI.getStrValue(strTemp2," Dept : ","","");
		%>
     <tr bgcolor="#FFFFFF" class="thinborder">
       <td height="25" colspan="17" class="thinborder">&nbsp;<%=strTemp2%></td>
     </tr>
		 <%}// bolNextDept || bolMoveNextPage)%>
 <%for(; iNumRec < vRetResult.size();){// employee for loop
	i = iNumRec;
	vSalDetails = (Vector)vRetResult.elementAt(i+10);
	vPrevSal = (Vector)vRetResult.elementAt(i+11);
	if(i+iFieldCount+1 < vRetResult.size()){
		if(i == 0){
			strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");
			strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+13),"");
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 12),"0");
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 13),"");
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
     <tr bgcolor="#FFFFFF" class="thinborder">
      <%
		strTemp = (String)vRetResult.elementAt(i+1);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td>
      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
      <%
			//System.out.println("vSalDetails " + vSalDetails);
			for(iMonth = 0;iMonth < 12; iMonth++){
				strTemp = null;
				iObjMonth = new Integer(iMonth);
				iIndexOf = vSalDetails.indexOf(iObjMonth);
				if(iIndexOf != -1){
					vSalDetails.remove(iIndexOf);
					if(strSalaryType.equals("2"))
						strTemp = (String)vSalDetails.elementAt(iIndexOf+2);
					else if(strSalaryType.equals("1"))
						strTemp = (String)vSalDetails.elementAt(iIndexOf+1);
					else{
						strTemp = (String)vSalDetails.elementAt(iIndexOf);
						if(WI.fillTextValue("less_deductions").length() > 0){
							strTemp = CommonUtil.formatFloat(strTemp, true);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
							dTotal = Double.parseDouble(strTemp);

							strTemp = (String)vSalDetails.elementAt(iIndexOf+5);// awol
							strTemp = CommonUtil.formatFloat(strTemp, true);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
							dTotal -= Double.parseDouble(strTemp);

							if(!strSchCode.startsWith("VMUF")){
								strTemp = (String)vSalDetails.elementAt(iIndexOf+6);// late_under_amt
								strTemp = CommonUtil.formatFloat(strTemp, true);
								strTemp = ConversionTable.replaceString(strTemp, ",", "");
								dTotal -= Double.parseDouble(strTemp);
							}

							strTemp = (String)vSalDetails.elementAt(iIndexOf+7);// faculty_absence
							strTemp = CommonUtil.formatFloat(strTemp, true);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
							dTotal -= Double.parseDouble(strTemp);

							strTemp = (String)vSalDetails.elementAt(iIndexOf+8);// leave_deduction_amt
							strTemp = CommonUtil.formatFloat(strTemp, true);
							strTemp = ConversionTable.replaceString(strTemp, ",", "");
							dTotal -= Double.parseDouble(strTemp);
							strTemp = Double.toString(dTotal);
						}
					}
				}
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				if(dTemp == 0d)
					strTemp = "";
				adDeptMonthly[iMonth] += dTemp;
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%}%>
			<%
				strTemp = null;
				if(strSalaryType.equals("2"))
					strTemp = (String)vPrevSal.elementAt(2);
				else if(strSalaryType.equals("1"))
					strTemp = (String)vPrevSal.elementAt(1);
				else
					strTemp = (String)vPrevSal.elementAt(0);
				strTemp = CommonUtil.formatFloat(strTemp, true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dDeptTotalAdjust += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
			%>
			<td align="right" class="thinborder" ><%=strTemp%>&nbsp;</td>
      <%
		  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7), true);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dDeptTotalBonus += dTemp;
		  %>
      <td align="right" class="thinborder" ><%=strTemp%>&nbsp;</td>
      <%if(WI.fillTextValue("show_signature").length() > 0){%>
			<td align="right" class="thinborder" >&nbsp;</td>
			<%}%>
    </tr>
<%
 	 iNumRec+=iFieldCount;
	 iIncr++;
	 if(iNumRec < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(iNumRec+12),"0");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(iNumRec+13),"");
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
		 <tr bgcolor="#FFFFFF" class="thinborder">
       <td height="25" colspan="2" class="thinborder">DEPARTMENT TOTAL:</td>
       <%for(iMonth = 0;iMonth < 12; iMonth++){%>
			 <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adDeptMonthly[iMonth], true)%>&nbsp;</td>
			 <%}%>
       <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dDeptTotalAdjust, true)%>&nbsp;</td>
       <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dDeptTotalBonus, true)%>&nbsp;</td>
			 <%if(WI.fillTextValue("show_signature").length() > 0){%>
       <td align="right" class="thinborder" >&nbsp;</td>
			 <%}%>
     </tr>
	    <%
		}// if(bolOfficeTotal || (!bolOfficeTotal && iNumRec >= vRetResult.size()))
		%>
			<%if(iNumRec >= vRetResult.size()){%>
		 <tr bgcolor="#FFFFFF" class="thinborder">
		   <td class="thinborder" >&nbsp;</td>
		   <td height="25" class="thinborder" >&nbsp;</td>
			 <%for(iMonth = 0;iMonth < 12; iMonth++){%>
		   <td align="right" class="thinborder">&nbsp;</td>
			 <%}%>
		   <td align="right" class="thinborder" >&nbsp;</td>
		   <td align="right" class="thinborder" >&nbsp;</td>
			 <%if(WI.fillTextValue("show_signature").length() > 0){%>
		   <td align="right" class="thinborder" >&nbsp;</td>
			 <%}%>
	   </tr>
			<%}/// bolPageBreak || iNumRec >= vRetResult.size()%>
	<%
		if(bolPageBreak){
			iCount = 0;
			break;
		}
	 }// end DEPT FOR LOOP %>
  </table>

	<%if(strSchCode.startsWith("VMUF")){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" colspan="10" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" class="NoBorder">CERTIFIED CORRECT BY</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("accounting_head").toUpperCase()%><br>
          </strong>HEAD, ACCOUNTING SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("benefit_head").toUpperCase()%><br>
          </font></strong><font size="1">HEAD, BENEFIT SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("payroll_head").toUpperCase()%></strong><br>
          HEAD, PAYROLL SECTION </font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="14">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3"><font size="1"><strong>APPROVED FOR PAYMENT</strong></font></td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("president").toUpperCase()%><br>
      </font></strong><font size="1">PRESIDENT</font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("vp_finance").toUpperCase()%><br>
          </font></strong><font size="1">CTTP/VP-Finance</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="5%" height="18">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
    </tr>
  </table>
	<%}%>

	<%if (iNumRec < vRetResult.size()){%>
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
