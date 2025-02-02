<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Philhealth Remittance Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLEFTRIGHT {
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderTOPLEFTRIGHT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPBOTTMLEFTRIGHT {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}



TD.thinborderTOP {
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.noBorder{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","phic_monthly.jsp");

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
														"phic_monthly.jsp");
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

  Vector vRetResult = null;
  Vector vEmployerInfo = null;
  PRRemittance PRRemit = new PRRemittance(request);
  double dTemp  = 0d;
  double dLineTotal  = 0d;
  double dPageTotal = 0d;
  double dPageEmployer = 0d;
  double dPagePersonal = 0d;
  double dGrandEmployer = 0d;
  double dGrandPersonal = 0d;
  double dGrandTotal = 0d;
  
  double dDeptPagePersonal = 0d;
  double dDeptPageEmployer = 0d;
  double dDeptPageTotal = 0d;


  String[] astrMonth = {"January","February","March","April","May","June","July",
						  "August", "September","October","November","December"};
						  
  String[] astrPtFt = {"PART-TIME","FULL-TIME"};
  String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
  boolean bolPageBreak  = false;
	boolean showHeader  = true;  
	

  vRetResult = PRRemit.PHICMonthlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(21*iMaxRecPerPage);	
	if(vRetResult.size() % (21*iMaxRecPerPage) > 0) ++iTotalPages;
	for (;iNumRec < vRetResult.size();iPage++){
	dPagePersonal = 0d;
	dPageEmployer = 0d;
	dPageTotal = 0d;
%>

<body onLoad="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2" class="noBorder"><div align="center">Republic of the Philippines<br>
      PHILIPPINE HEALTH INSURANCE CORPORATION </div></td>
    </tr>
  <tr>
    <td height="28" colspan="2" class="noBorder">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="24%" class="noBorder">REGISTERED EMPLOYER NAME:</td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>
        <td width="38%" class="noBorder">&nbsp;<%=strTemp%></td>
        <td width="16%" class="noBorder">EMPLOYER ID NO. </td>
        <td width="14%">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="10%" class="noBorder">ADDRESS: </td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
        <td width="52%" class="noBorder">&nbsp;<%=strTemp%></td>
        <td width="13%" class="noBorder">EMPLOYER TIN: </td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(7);
			else
				strTemp = "";
		%>			
        <td width="25%" class="noBorder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="67%" class="noBorder">&nbsp;</td>
    <td width="33%" class="noBorder"> FOR THE MONTH : <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></td>
  </tr>
  <tr>
    <td colspan="2" class="noBorder">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" class="noBorder"><div align="center">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="20%">&nbsp;</td>
          <td width="60%" align="center" class="noBorder">MEDICARE CONTRIBUTION </td>
          <td width="20%" align="right" class="noBorder">Page: <%=iPage%> of <%=iTotalPages%>&nbsp;&nbsp;</td>
        </tr>
      </table>
    </div></td>
    </tr>
  <tr>
    <td colspan="2" class="noBorder">&nbsp;</td>
  </tr>
</table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  
  <tr>
    <td colspan="7">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="7" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  
  <tr>
    <td width="30%" height="27" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME</td>
    <%
			if(WI.fillTextValue("number_option").equals("1")){
				strTemp = "PHILHEALTH NO.";
			}else{
				strTemp = "GSIS POLICY NO. ";
			}
		%>
    <td width="9%" align="center" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
    <td width="18%" align="center" class="thinborderBOTTOMLEFT">POSITION TITLE </td>
    <%if(WI.fillTextValue("show_monthly").length() > 0){%>
		<td width="12%" align="center" class="thinborderBOTTOMLEFT">MONTHLY COMPENSATION </td>
		<%}%>
    <td width="11%" align="center" class="thinborderBOTTOMLEFT">PERSONAL SHARE </td>
    <td width="9%" align="center" class="thinborderBOTTOMLEFT">EMPLOYER SHARE </td>
    <td width="11%" align="center" class="thinborderBOTTOMLEFTRIGHT">TOTAL</td>
  </tr>
	<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=21,++iIncr, ++iCount){
		dLineTotal = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
	
	<%
		if(WI.fillTextValue("by_dept").length() > 0 ){
			if(showHeader){
				showHeader = false;
	%>
	<tr>
		<td colspan="7" height="23" class="thinborderBOTTOMLEFTRIGHT">&nbsp;
			<font size="1">
				<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong>
			</font>
		</td>
	</tr>
  		<%}
  	}%>
  
  <tr>
    <td height="16" class="thinborderLEFT">&nbsp;<font size="1"><%=iIncr%>. &nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></td>
    <%
			if(WI.fillTextValue("number_option").equals("1")){
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"&nbsp;");
			}else{
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14),"&nbsp;");
			}
		%>
    <td class="thinborderLEFT">&nbsp;<%=strTemp%></td>
    <td class="thinborderLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
		<%if(WI.fillTextValue("show_monthly").length() > 0){%>
    <% 
		strTemp = (String)vRetResult.elementAt(i+10);		
	%>
		<td class="thinborderLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
		<%}%>
    <% 
		strTemp = (String)vRetResult.elementAt(i+11);		
	%>
    <td class="thinborderLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPagePersonal += dTemp;
		dDeptPagePersonal += dTemp;
		dLineTotal += dTemp;		
		
	%>
	<% strTemp = (String)vRetResult.elementAt(i+12);%>
    <td class="thinborderLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPageEmployer += dTemp;	
		dDeptPageEmployer += dTemp;
		dLineTotal += dTemp;
		dPageTotal += dLineTotal;
		dDeptPageTotal += dPageTotal;
	%>	
    <td class="thinborderLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
    </tr>
	
	<%
		if( i+21 < vRetResult.size() ){
			if( !((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i+22))  
					|| !((String)vRetResult.elementAt(i+2)).equals((String)vRetResult.elementAt(i+23)) )
				showHeader = true;
		}			
	%>	
	
	<%if(WI.fillTextValue("by_dept").length() > 0 ){%>
			<%if( showHeader || i+21 >= vRetResult.size()){%>
			<tr>
				<td colspan="3" align="right" class="thinborderTOPLEFTBOTTOM">DEPARTMENT TOTAL --------------------------------------------------&gt; </td>
				<%if(WI.fillTextValue("show_monthly").length() > 0){%>
					<td align="right" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
				<%}%>
				<td align="right" class="thinborderTOPLEFTBOTTOM"><strong><%=CommonUtil.formatFloat(dDeptPagePersonal,true)%></strong>&nbsp;</td>
				<td align="right" class="thinborderTOPLEFTBOTTOM"><strong><%=CommonUtil.formatFloat(dDeptPageEmployer,true)%></strong>&nbsp;</td>
				<td align="right" class="thinborderTOPBOTTMLEFTRIGHT"><strong><%=CommonUtil.formatFloat((dDeptPagePersonal+dDeptPageEmployer),true)%></strong>&nbsp;</td>
			</tr>
	<%
				dDeptPagePersonal = 0d;
				dDeptPageEmployer = 0d;
				dDeptPageTotal = 0d;
			}	
		}
	%>
	
  <%}%>
  <tr>
    <td colspan="3" align="right" class="thinborderTOPLEFT">TOTAL FOR THIS PAGE -------------------------------------------------&gt; </td>
	  <%
	dGrandPersonal += dPagePersonal;
	dGrandEmployer += dPageEmployer;	
	dGrandTotal += dPageTotal;
	%>
		<%if(WI.fillTextValue("show_monthly").length() > 0){%>
		<td align="right" class="thinborderTOPLEFT">&nbsp;</td>
		<%}%>
    <td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dPagePersonal,true)%>&nbsp;</td>
    <td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dPageEmployer,true)%>&nbsp;</td>
    <td align="right" class="thinborderTOPLEFTRIGHT"><%=CommonUtil.formatFloat(dPageTotal ,true)%>&nbsp;</td>
  </tr>
  <%if ( iNumRec >= vRetResult.size()) {%>
  <tr>
    <td colspan="3" align="right" class="thinborderTOPLEFT">GRAND TOTAL -----------------------------------------------------------&gt; </td>
    <%if(WI.fillTextValue("show_monthly").length() > 0){%>
		<td align="right" class="thinborderTOPLEFT">&nbsp;</td>
		<%}%>
		<td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dGrandPersonal,true)%>&nbsp;</td>
    <td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dGrandEmployer,true)%>&nbsp;</td>
    <td align="right" class="thinborderTOPLEFTRIGHT"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
  </tr>
  <%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="2%" colspan="2" class="thinborderTOP">&nbsp;</td>
    <!--<td width="25%" align="center" class="thinborderTOP">PREPARED BY: </td>-->
    <td width="2%" class="thinborderTOP"><div align="center">&nbsp;</div></td>
    <!--<td width="26%" align="center" class="thinborderTOP">CERTIFIED CORRECT: </td>-->
    <td width="45%" class="thinborderTOP">&nbsp;</td>
    </tr>
  <tr>
    <td height="34" colspan="2">&nbsp;</td>
    <!--<td valign="bottom" nowrap class="thinborderBOTTOM"><strong><%=WI.fillTextValue("prepared_by").toUpperCase()%>&nbsp;<%=WI.getStrValue(WI.fillTextValue("designation"),"(",")","")%></strong></td>-->
    <td>&nbsp;</td>
	<!--<td valign="bottom" nowrap class="thinborderBOTTOM"><strong><%=WI.fillTextValue("certified_by").toUpperCase()%>&nbsp;<%=WI.getStrValue(WI.fillTextValue("designation2"),"(",")","")%></strong></td>-->
    <td>&nbsp;</td>
    </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <!--<td align="center" class="noBorder">NAME/ DESIGNATION </td>-->
    <td class="noBorder"><div align="center"></div></td>
    <!--<td align="center" class="noBorder">NAME/ DESIGNATION</td>-->
    <td>&nbsp;</td>
    </tr>
</table>

  <%if (bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
  <%}//page break ony if it is not last page.
  } //end for (iNumRec < vRetResult.size()%>

<%}// if vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>