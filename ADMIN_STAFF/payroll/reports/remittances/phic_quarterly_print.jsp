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
<title>Payroll Payslip</title>
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

TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.noBorder{
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
TD.thinborderBOTTOMRIGHT {
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLEFTRIGHT {
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
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


function printPage(){
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	window.print();
	
}

function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}


</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<body>
<form name="form_">
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
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","phic_quarterly_print.jsp");

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
														"phic_quarterly_print.jsp");
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

String strSchCode = dbOP.getSchoolIndex();
String[] astrQuarterName = {"January - March", "April - June", "July - September", "October - December"};

boolean bolIncremented = false;
boolean bolNextEmp = false;

double dTemp = 0d;
double dPS1 = 0d;
double dPS2 = 0d;
double dPS3 = 0d;

double dES1 = 0d;
double dES2 = 0d;
double dES3 = 0d;

double dESPS1 = 0d;
double dESPS2 = 0d;
double dESPS3 = 0d;

boolean bolFirst = false;
boolean bolSecond = false;
boolean bolThird = false;
boolean bolPageBreak = false;

String strMonth  = null;
String strBracket1 = null;
String strBracket2 = null;
String strBracket3 = null;
int iMonth = 0;
	
int i = 0;
int iTemp = 0;

int iCount1 = 0;
int iCount2 = 0;
int iCount3 = 0;

String strPS = null;
String strES = null;
String strEmpType = "5";
String[] astrEmpType = {"", "P  - Private", "LGU", "GCC", "NGA"};
String strEmpIndex = null;

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.PHICQuarterlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0)
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}
if (vRetResult != null && vRetResult.size() > 0 ){
	if(vEmployerInfo != null && vEmployerInfo.size() > 0)
		strEmpType = (String)vEmployerInfo.elementAt(2);
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	 for (;iNumRec < vRetResult.size();){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><div align="center"></div></td>
      <td colspan="8" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="14%" rowspan="4" align="center" class="thinborderBOTTOMLEFT"><strong>&nbsp;<font size="+3">RF-1</font></strong></td>
      <td width="17%" class="thinborderLEFT"><strong><font size="3">EMPLOYER'S </font></strong></td>
      <td colspan="6" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font size="3">FOR PHILHEALTH USE</font></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="thinborderLEFT"><strong><font size="3">QUARTERLY</font></strong></td>
      <td colspan="2" class="thinborderLEFT">Date Screened:</td>
      <td width="12%" class="noBorder">Action taken:</td>
      <td width="7%">&nbsp;</td>
      <td colspan="2" class="thinborderLEFTRIGHT">Date Received:</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="thinborderLEFT"><strong><font size="3">REMITTANCE</font></strong></td>
      <td width="6%" class="thinborderLEFT">By:</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="5%" class="thinborderLEFT">By:</td>
      <td width="23%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOMLEFT"><strong><font size="3">REPORT</font></strong></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td colspan="2" align="center" class="thinborderBOTTOM">Signature over Printed Name</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="center" class="thinborderBOTTOMRIGHT">Signature over Printed Name</td>
    </tr>
  </table>	
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="14%" class="noBorder">&nbsp;</td>
      <td width="30%">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">PHILHEALTH NO.</td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(8);
			else
				strTemp = "";
		%>			  
      <td><span class="thinborderBOTTOM">&nbsp;<%=strTemp%></span></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">EMPLOYER TIN</td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(7);
			else
				strTemp = "";
		%>		  
      <td>&nbsp;<%=strTemp%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">EMPLOYER SSS</td>
		<%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(6);
			else
				strTemp = "";
		%>		  
      <td><span class="thinborderBOTTOM">&nbsp;<%=strTemp%></span></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">EMPLOYER NAME</td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>			
      <td class="thinborderBOTTOM">&nbsp;<strong><%=strTemp%></strong></td>
      <td class="noBorder">EMPLOYER TYPE: </td>
	  <%
			strTemp = astrEmpType[Integer.parseInt(strEmpType)];
	  %>		  
      <td><%=strTemp%></td>
      <td class="noBorder"><div align="right">APPLICABLE QUARTER:</div></td>
      <td>&nbsp;<%=Integer.parseInt(WI.getStrValue(WI.fillTextValue("quarter"),"0"))+1%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td class="noBorder">MAILING ADDRESS</td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	 
      <td class="thinborderBOTTOM">&nbsp;<strong><%=strTemp%></strong></td>
      <td class="noBorder">TYPE OF REPORT: </td>
      <td colspan="2">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="34%">R</td>
            <td width="66%">Regular RF - 1 </td>
          </tr>
        </table></td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td height="19" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM"><span class="noBorder">Tel. No. </span></td>
	<%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String)vEmployerInfo.elementAt(5);
		else
			strTemp = "";
	%>		  
      <td class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>	
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">  
  <tr>
    <td class="thinborderLEFT">&nbsp;</td>
    <td colspan="3" class="thinborderLEFT">&nbsp;</td>
    <td rowspan="3" align="center" class="thinborderBOTTOMLEFT">PIN / SSS </td>
    <td colspan="3" rowspan="2" align="center" class="thinborderBOTTOMLEFT">BRACKET MONTHLY </td>
    <td colspan="6" align="center" class="thinborderBOTTOMLEFT">        NHIP PREMIUM CONRIBUTIONS      </td>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">      <center>
      </center>      </td>
  </tr>
  <tr>
    <td class="thinborderLEFT">&nbsp;</td>
    <td colspan="3" align="center" class="thinborderBOTTOMLEFT">N A M E &nbsp;&nbsp;O F&nbsp; &nbsp;E M P L O Y E E S </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">        1ST MONTH      </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">        2ND MONTH      </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">        3RD MONTH      </td>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">        REMARKS      </td>
    </tr>
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;SURNAME</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;GIVEN NAME </td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(strSchCode.startsWith("WUP")?"MIDDLE NAME" : "MI")%></td>
    <td align="center" class="thinborderBOTTOMLEFT">1ST</td>
    <td align="center" class="thinborderBOTTOMLEFT">2ND</td>
    <td align="center" class="thinborderBOTTOMLEFT">3RD</td>
    <td align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td class="thinborderBOTTOMLEFTRIGHT"><font size="1">S-Separated, NE-No Earnings, NH-Newly Hired</font></td>
    </tr>
      <% 
		
		for(iCount = 1; iNumRec<vRetResult.size(); ++iIncr, ++iCount){
			i = iNumRec;
		  bolFirst = false;
		  bolSecond = false;
		  bolThird = false;
			strBracket1 = "";
			strBracket2 = "";
			strBracket3 = "";
			strEmpIndex = (String)vRetResult.elementAt(i);		
		
		iTemp = i;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	   %>
  <tr>
    <td width="2%" class="thinborderBOTTOMLEFT"><%=iCount%></td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = WI.getStrValue(strTemp,"");
		if(strTemp.length() > 0 && !strSchCode.startsWith("WUP") )
			strTemp = strTemp.substring(0,1) + ".";		
	%>	
    <td width="9%" class="thinborderBOTTOMLEFT">&nbsp;<%=(strTemp).toUpperCase()%></td>
    <td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		<% for(; i < vRetResult.size();){
	  strMonth = (String)vRetResult.elementAt(i+13);	  
	  iMonth = Integer.parseInt(strMonth);
	  strMonth = Integer.toString((iMonth%3)+1);
		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;
	  if(strMonth.equals("1")){
		  strBracket1 = (String)vRetResult.elementAt(i+12);
		  iNumRec = iNumRec + 14;
		  bolIncremented = true;
		  bolFirst = true;			
	  }else
		  strBracket1 = "";	  
		
		i = iNumRec;
	   if(i >= vRetResult.size()){
	  		break;
	 	 }		
		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;
		 
	  // okay here is the logic... 
		strMonth = (String)vRetResult.elementAt(i+13);
		iMonth = Integer.parseInt(strMonth);
		strMonth = Integer.toString((iMonth%3)+1);
		if(strMonth.equals("2")){
			strBracket2 = (String)vRetResult.elementAt(i+12);
			iNumRec = iNumRec + 14;
			bolIncremented = true;
			bolSecond = true;
		}else
			strBracket2 = "";
   
	  i = iNumRec;
		if(i >= vRetResult.size()){
	  		break;
	 	 }
		
		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;
	  
			strMonth = (String)vRetResult.elementAt(i+13);
			iMonth = Integer.parseInt(strMonth);
			strMonth = Integer.toString((iMonth%3)+1);
			if(strMonth.equals("3")){
					strBracket3 = (String)vRetResult.elementAt(i+12);
					iNumRec = iNumRec + 14;
				bolIncremented = true;
				bolThird = true;
			}else
				strBracket3 = "";
				
			break;
			}
	  %>
	<td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strBracket1,"&nbsp;")%>&nbsp;</div></td>
  <td width="5%" class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strBracket2,"&nbsp;")%>&nbsp;</div></td>
  <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(strBracket3,"&nbsp;")%>&nbsp;</div></td>
	<% dTemp = 0d;
  	  if(bolFirst){
		strPS = (String)vRetResult.elementAt(iTemp+10);		
		iCount1++;
	  }else
	  	strPS ="";
	  
	  strTemp = ConversionTable.replaceString(strPS,",","");	  
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPS1 += dTemp;			
	%>
    <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</div></td>
	<%
  	  if(bolFirst){		
		  strES = (String)vRetResult.elementAt(iTemp+11);		  
		  iTemp = iTemp + 14;
	  }else
	  	strES ="";	
	  strTemp = ConversionTable.replaceString(strES,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dES1 += dTemp;		
	%>
    <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</div></td>
	<%
  	  if(bolSecond){
		strPS = (String)vRetResult.elementAt(iTemp+10);		
		iCount2++;
	  }else
	  	strPS ="";

	  strTemp = ConversionTable.replaceString(strPS,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPS2 += dTemp;				
	%>
    <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</div></td>
	<%
  	  if(bolSecond){
		strES = (String)vRetResult.elementAt(iTemp+11);
		iTemp = iTemp + 14;
	  }else
	  	strES ="";

	  strTemp = ConversionTable.replaceString(strES,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dES2 += dTemp;		
	%>
    <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</div></td>
	<%
  	  if(bolThird){
		strPS = (String)vRetResult.elementAt(iTemp+10);		
		iCount3++;		
	  }else
	  	strPS ="";

	  strTemp = ConversionTable.replaceString(strPS,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dPS3 += dTemp;
		
			
	%>
    <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</div></td>
	<%
  	  if(bolThird){
		strES = (String)vRetResult.elementAt(iTemp+11);
	  }else
	  	strES ="";

	  strTemp = ConversionTable.replaceString(strES,",","");
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dES3 += dTemp;		
	%>
    <td width="6%" align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</td>
    <td width="5%" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="33%" align="center"><font color="#FF0000">&nbsp;</font><font color="#FF0000"><label id="first<%=i%>" 
				onclick="setLabelText('first<%=i%>','Remarks for first month ')">
				 -- </label>
        </font></td>
        <td width="33%" align="center" class="thinborderLEFT"><font color="#FF0000">&nbsp;</font><font color="#FF0000"><label id="second<%=i%>" 
				onclick="setLabelText('second<%=i%>','Remarks for Second month ')">
				 -- </label>
        </font></td>
        <td width="33%" class="thinborderLEFT"><font color="#FF0000">&nbsp;</font><font color="#FF0000"><label id="third<%=i%>" 
				onclick="setLabelText('third<%=i%>','Remarks third month ')">
				 -- </label>
        </font></td>
      </tr>
    </table></td>
    </tr>
  <%
	   if(!bolIncremented)
  		break;
	}	
	for(;iCount<=iMaxRecPerPage; ++iCount){%>	
  <tr>
    <td width="2%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="9%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="5%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="5%" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="33%">&nbsp;</td>
        <td width="33%" class="thinborderLEFT">&nbsp;</td>
        <td width="33%" class="thinborderLEFT">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
   <%}%>
	
  <%if(iNumRec >= vRetResult.size()){%>
   <tr>
     <td colspan="5" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="3" align="center" class="thinborderBOTTOMLEFT">SUB TOTAL</td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dPS1,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dES1,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dPS2,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dES2,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dPS3,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dES3,true)%>&nbsp;</div></td>
     <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
   <tr>
     <td colspan="5" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="3" align="center" class="thinborderBOTTOMLEFT">(PS+ES)</td>
     <td colspan="2" class="thinborderBOTTOMLEFT"><div align="center"><%=CommonUtil.formatFloat(dPS1 + dES1,true)%></div></td>
     <td colspan="2" class="thinborderBOTTOMLEFT"><div align="center"><%=CommonUtil.formatFloat(dPS2 + dES2,true)%></div></td>
     <td colspan="2" class="thinborderBOTTOMLEFT"><div align="center"><%=CommonUtil.formatFloat(dPS3 + dES3,true)%></div></td>
     <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
   <%}else{%>
   <tr>
     <td colspan="5" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="3" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
   </tr>
   <tr>
     <td colspan="5" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="3" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
     <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
   </tr>
	<%}%>
   <!--
   <tr>
     <td width="2%">&nbsp;</td>
     <td width="12%">&nbsp;</td>
     <td width="13%">&nbsp;</td>
     <td width="4%">&nbsp;</td>
     <td width="7%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="5%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="6%">&nbsp;</td>
     <td width="3%">&nbsp;</td>
    </tr>
	-->
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">     
   <tr>
     <td height="19">&nbsp;</td>
     <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
     <td align="right">CERTIFIED CORRECT:&nbsp;</td>
     <td valign="bottom" class="thinborderBOTTOM"><strong> &nbsp;<%=WI.fillTextValue("signatory").toUpperCase()%> </strong></td>
   </tr>
   <tr>
     <td>&nbsp;</td>
     <td colspan="5" rowspan="6" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td colspan="3" class="thinborderBOTTOMLEFT">ME-5 SUMMARY OF CONTRIBUTION PAYMENTS</td>
           <td width="24%" rowspan="2" class="thinborderBOTTOMLEFTRIGHT">No. of Employees</td>
         </tr>
         <tr>
           <td width="25%" class="thinborderBOTTOMLEFT"><div align="center">Monthly / Quarterly</div></td>
           <td width="28%" class="thinborderBOTTOMLEFT"><div align="center">Total Contribution</div></td>
           <td width="23%" class="thinborderBOTTOMLEFT"><div align="center">Rec. no. / Date Paid</div></td>
         </tr>
         <tr>
           <td class="thinborderBOTTOMLEFT">1st Month</td>
           <td class="thinborderBOTTOMLEFT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=CommonUtil.formatFloat(dPS1 + dES1,true)%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>		   
		   </div></td>
           <td class="thinborderBOTTOMLEFT">&nbsp;</td>
		   
           <td class="thinborderBOTTOMLEFTRIGHT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=iCount1%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>
		   </div></td>
         </tr>
         <tr>
           <td class="thinborderBOTTOMLEFT">2nd Month</td>
           <td class="thinborderBOTTOMLEFT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=CommonUtil.formatFloat(dPS2 + dES2,true)%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>			   
		   </div></td>
           <td class="thinborderBOTTOMLEFT">&nbsp;</td>
           <td class="thinborderBOTTOMLEFTRIGHT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=iCount2%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>		   		   
		   </div></td>
         </tr>
         <tr>
           <td class="thinborderBOTTOMLEFT">3rd Month</td>
           <td class="thinborderBOTTOMLEFT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=CommonUtil.formatFloat(dPS3 + dES3,true)%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>			   
		   </div></td>
           <td class="thinborderBOTTOMLEFT">&nbsp;</td>
           <td class="thinborderBOTTOMLEFTRIGHT"><div align="right">
		   <%if(iNumRec >= vRetResult.size()){%>
		   <%=iCount3%>&nbsp;
		   <%}else{%>		   
		   &nbsp;
		   <%}%>		   
		   </div></td>
         </tr>
          </table></td>
     <td>&nbsp;</td>
     <td valign="bottom" class="noBorder"><span class="thinborderBOTTOMLEFT">Signature over Printed Name</span></td>
   </tr>
   <tr>
     <td height="18">&nbsp;</td>
     <td>&nbsp;</td> 	 
     <td valign="bottom" class="thinborderBOTTOM">&nbsp;<strong><%=WI.fillTextValue("designation")%></strong></td>
   </tr>
   <tr>
     <td>&nbsp;</td>
     <td>&nbsp;</td>
     <td valign="bottom" class="noBorder">Official Designation</td>
   </tr>
   <tr>
     <td height="19">&nbsp;</td>
     <td>&nbsp;</td>
     <td valign="bottom" class="thinborderBOTTOM">&nbsp;<%=WI.getTodaysDate(6)%></td>
   </tr>
   <tr>
     <td>&nbsp;</td>
     <td>&nbsp;</td>
     <td class="noBorder">Date</td>
   </tr>
   <tr>
     <td width="2%" height="18">&nbsp;</td>
     <td width="36%">&nbsp;</td>
     <td width="27%">&nbsp;</td>
    </tr>
</table>
  <%if (iNumRec < vRetResult.size()){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
  <%}//page break ony if it is not last page.  
   } //end for (iNumRec < vRetResult.size()%>

<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" id="footer">
  <tr>
    <td><hr/></td>
  </tr>
  <tr>
    <td><div align="center">
	<a href="javascript:printPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0" /></a><font size="1">print form </font></div></td>
  </tr>
  <tr>
    <td height="30"><font size="2"><strong>Note: 
	  <font style="font-size:11px">Items in <font color="#FF0000">RED</font> are editable for printing purposes only </font><br>Set Printer to black / white mode before printing</strong></font></td>
  </tr>
</table>      
  <%} // if (vRetResult != null && vRetResult.size() > 0 )%>  
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>