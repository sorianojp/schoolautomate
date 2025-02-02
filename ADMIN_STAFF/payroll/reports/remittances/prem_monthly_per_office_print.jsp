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
<title>Monthly remittance print per office</title>
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
	font-size: 9px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
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
	String strPayrollPeriod  = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","prem_monthly_per_office.jsp");

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
														"prem_monthly_per_office.jsp");
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
PRRemittance PRRemit = new PRRemittance(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};

double dTemp = 0d;
int i = 0;
int j = 0;
int iTotalEmp = 0;
int iRecord = 0;
double dShare = 0d;
double dTotalShare = 0d;
Vector vRows = null;
Vector vColumns = null;
Vector vRowCol = null;
int iRowCount = 1;
int iColCount = 1;
String strPremiumType = WI.getStrValue(WI.fillTextValue("premium_type"),"0");
String strPremiumName = "";
if(strPremiumType.equals("1")){
	strPremiumName = "SSS";
}else{
	strPremiumName = "Philhealth";
}

  vRetResult = PRRemit.generateRemitancesPerOffice(dbOP);
  if(vRetResult != null){
	vRows = (Vector)vRetResult.elementAt(0);
	vColumns = (Vector)vRetResult.elementAt(1);  	
  }  
%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <%if (vColumns != null && vColumns.size() > 0 && vRows != null && vRows.size() > 0 ){
  int[] iColTotal= new int[vColumns.size()];
  %>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
      </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><div align="center">Summary of <strong><%=strPremiumName%></strong> Premiums </div></td>
      </tr>
      <tr>
        <td><div align="center">For the Period <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></div></td>
      </tr>
      <tr>
        <td class="thinborderBOTTOM">&nbsp;</td>
      </tr>
  </table>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">      
      <tr>
        <td class="thinborderBOTTOMLEFT">&nbsp;</td>
        <td class="thinborderBOTTOMLEFT">&nbsp;</td>
        <td class="thinborderBOTTOMLEFT">&nbsp;</td>
		<%for(j = 0;j < vColumns.size(); j ++,iColCount++){%>
        <td class="thinborderBOTTOMLEFT"><div align="center"><%=iColCount%></div></td>
		<%}%>
        <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      </tr>
      <tr>
        <td width="5%" class="thinborderBOTTOMLEFT">&nbsp;</td>
        <td width="8%" class="thinborderBOTTOMLEFT"><div align="center"><strong>&nbsp;Dept/Office Code</strong></div></td>
        <td width="9%" class="thinborderBOTTOMLEFT"><div align="center"><strong>Number of Employees </strong></div></td>
		<%for(j = 0;j < vColumns.size(); j++){
		iColTotal[j] = 0;
		%>
        <td width="6%" class="thinborderBOTTOMLEFT"><div align="center"><strong><%=CommonUtil.formatFloat((String)vColumns.elementAt(j),true)%></strong></div></td>
		<%}%>
        <td width="72%" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><strong>AMOUNT</strong></div></td>
      </tr>
	  <%
	  for(i = 0; i < vRows.size();i+=8,iRowCount++){
	  vRowCol = (Vector)vRows.elementAt(i+6);
	  dShare = 0d;		  
	  %>
      <tr>
        <td class="thinborderBOTTOMLEFT">&nbsp;<%=iRowCount%></td>
	  	<%
			strTemp = (String)vRows.elementAt(i+2);
			if(strTemp != null && strTemp.equals("null"))
				strTemp = null;
			if(strTemp == null)
				strTemp = (String)vRows.elementAt(i+3);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRows.elementAt(i+4);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRows.elementAt(i+5);				
		%>
        <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
        <td height="18" class="thinborderBOTTOMLEFT"><div align="right"><%=(String)vRows.elementAt(i+7)%>&nbsp;</div></td>
		<%
			iTotalEmp += Integer.parseInt((String)vRows.elementAt(i+7));
		%>
		<%for(j = 0;j < vRowCol.size(); j+=2){
			strTemp = (String)vRowCol.elementAt(j);
			dShare += Integer.parseInt(strTemp) * Double.parseDouble((String)vRowCol.elementAt(j+1));
			iColTotal[(j/2)] = iColTotal[(j/2)] + Integer.parseInt(strTemp);
			if(strTemp.equals("0"))
				strTemp = "";
			
		%>
        <td class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
		<%}
		dTotalShare += dShare;
		%>
        <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dShare,true)%>&nbsp;</div></td>
      </tr>
	  <%}%>
      <tr>
        <td height="18" colspan="3" class="thinborderBOTTOMLEFT">TOTAL EMPLOYEES: <%=iTotalEmp%></td>
		<%for(j = 0;j < vRowCol.size(); j+=2){%>		
        <td class="thinborderBOTTOMLEFT"><div align="right"><%=iColTotal[(j/2)]%>&nbsp;</div></td>
		<%}%>
        <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dTotalShare,true)%>&nbsp;</div></td>
      </tr>
    </table>
    <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>