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
<title>GSIS LOANS MONTHLY REMITTANCES</title>
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
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMRIGHT {
	border-bottom: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderTOPLEFT {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size:10px;
}

TD.thinborderTOPRIGHT {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderRIGHT {
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2); //I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;
	boolean bolHasInternal = false;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","gsis_monthly.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");										

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
														"gsis_monthly.jsp");
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

//end of authenticaion code.

Vector vRetResult = null;
PRRemittance PRRemit = new PRRemittance(request);
double dTemp  = 0d;
double dLineTotal  = 0d;
double dPageTotal = 0d;
double dEETotal = 0d;
double dERTotal = 0f;
Vector vEmployerInfo  = null;
String strEmpType   = "5";
boolean bolPageBreak = false;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};
String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
int i = 0;
   vRetResult = PRRemit.GSISMonthlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strEmpType = (String)vEmployerInfo.elementAt(2);
		
		int iPage = 1; 
		int iCount = 0;
		int iRowCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-1)/(25*iMaxRecPerPage);	
	    if((vRetResult.size()-1) % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	   dPageTotal = 0d;
	   dEETotal = 0d;
	   dERTotal = 0f;
%>

<body onLoad="window.print();">
<form name="form_">
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td width="79%" height="16"><div align="center"><strong>GSIS  PREMIUM REMITTANCES </strong></div></td>
    </tr>
    <tr>
	 <%
	 if(strEmpType.equals("1"))
		strTemp = "FOR PRIVATE EMPLOYER";
	 else
		strTemp = "FOR GOVERNMENT EMPLOYER";
	 %>		
      <td height="18" valign="bottom"><div align="center"><%=strTemp%></div></td>
    </tr>
    <tr>
	  <%
		 if(strEmpType.equals("2"))
			strTemp = "LOCAL GOVERNMENT UNIT";
		 else if(strEmpType.equals("3"))
			strTemp = "GOVERNMENT CONTROLLED CORP.";
		 else if(strEmpType.equals("4"))
			strTemp = "NATIONAL GOVERNMENT AGENCY ";				
		 else
			strTemp = "";			 	
	  %>		
      <td height="18" valign="bottom"><div align="center"><%=WI.getStrValue(strTemp, "<<< "," >>>","&nbsp;")%></div></td>
    </tr>
  </table>   
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">&nbsp;</td>
      <td width="17%" height="18" align="center" class="thinborderTOPLEFT"><strong>MONTH</strong></td>
      <td width="15%" align="center" class="thinborderTOPRIGHT"><strong>YEAR</strong></td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
      <td height="18" class="thinborderBOTTOMLEFT"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%></strong></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="center"><%=WI.fillTextValue("year_of")%></div></td>
    </tr>
    <tr>
      <td width="3%" height="18" valign="bottom" class="thinborderLEFT">&nbsp;</td>
      <td height="18" colspan="2" valign="bottom" class="thinborderNone">NAME OF EMPLOYER</td>
      <td height="18" class="thinborderLEFT">&nbsp;&nbsp;AGENCY CODE </td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(10);
        else
	        strTemp = "";
		  %>				
      <td height="18" class="thinborderRIGHT">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
    <tr >
      <td valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="2%" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>		
      <td width="63%" height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong>&nbsp;<%=strTemp%></strong></td>
	<%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String)vEmployerInfo.elementAt(4);
		else
			strTemp = "";
	%>		  
      <td height="18" colspan="2" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr >
      <td height="18" valign="bottom" class="thinborderLEFT">&nbsp;</td>
      <td height="18" colspan="2" valign="bottom" class="thinborderNone">ADDRESS OF EMPLOYER</td>
      <td height="18" class="thinborderLEFT">&nbsp;&nbsp;REGION CODE </td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(11);
        else
	        strTemp = "";
		  %>		
      <td class="thinborderRIGHT">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
    <tr >
      <td valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
      <td height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong>&nbsp;<%=strTemp%></strong></td>			  
      <td height="18" colspan="2" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="7" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  

  <tr>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME</td>
    <td align="center" class="thinborderBOTTOMLEFT">POLICY NUMBER </td>
    <td align="center" class="thinborderBOTTOMLEFT">MONTHLY SALARY</td>
    <td height="27" align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td align="center" class="thinborderBOTTOMLEFT">GS</td>
    <td align="center" class="thinborderBOTTOMLEFT">EC</td>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">TOTAL</td>
  </tr>
    <% 
		for(iCount = 1, iRowCount = 1; iNumRec<vRetResult.size(); iNumRec+=25,++iIncr, ++iCount, ++iRowCount){
		dLineTotal = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
  <tr>
		<%
			strTemp = WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), (String)vRetResult.elementAt(i+6), 4);
		%>
    <td width="30%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=(strTemp).toUpperCase()%></td>
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13));
		%>
    <td width="15%" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp.toUpperCase()%></td>
    <% 
		strTemp = (String)vRetResult.elementAt(i+17);		
		%>
	  <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
    <% 
		strTemp = (String)vRetResult.elementAt(i+10);		
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;		
	%>
    <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<% 
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;		
		%>
    <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;
	%>	
    <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"5");
	%>	
    <td width="11%" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
  <%}%>
</table>

  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="24" colspan="3" align="center"><strong>CERTIFIED CORRECT BY:</strong></td>
    </tr>
        <tr>
          <td height="24" align="center" valign="bottom">&nbsp;</td>
          <td height="24" align="center" valign="bottom" class="thinborderBOTTOM"><strong><%=WI.fillTextValue("signatory").toUpperCase()%></strong></td>
          <td height="24" align="center" valign="bottom">&nbsp;</td>
        </tr>
        <tr>
          <td width="20%" height="14" valign="bottom"><div align="center"></div></td>
          <td width="60%" height="14" align="center" valign="bottom">SIGNATURE OVER PRINTED NAME</td>
          <td width="20%" height="14" valign="bottom">&nbsp;</td>
        </tr>      
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>