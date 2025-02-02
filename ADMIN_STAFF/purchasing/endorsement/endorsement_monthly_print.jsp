<%@ page language="java" import="utility.*,purchasing.Endorsement,java.util.Vector" %>
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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11 px;	
}

TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.noBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

</style>
</head>
 <script language="JavaScript" src="../../../jscript/common.js"></script>

<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
 
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-ENDORSEMENT-Delete Endorsement details","endorsement_monthly_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Endorsement EN = new Endorsement();	
 	Vector vRetResult = null;	
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};	
	double dTemp = 0d;
	double dTotal = 0d;
	double dOfficeTotal = 0d;
	int iFieldCount = 12;
	int i = 0;
	int iCount = 0;
	int iItems = 1;
	boolean bolShowOffice = true;
	int iSearchResult = 0;

	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	
 	vRetResult = EN.getMonthlyIssuance(dbOP,request);

%>
<form name="form_">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder"><strong>MONTHLY REPORT<br>
      </strong><%=astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_of"))-1]%>&nbsp;<%=WI.fillTextValue("year_of")%></td>
    </tr>
    <tr> 
      <td width="11%" height="27" align="center" class="thinborder"><strong>DATE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="47%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>UNIT COST </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>TOTAL PRICE</strong></td>
    </tr>
    <%for(i = 0,iCount = 1;i < vRetResult.size();i+=iFieldCount,++iCount){ %>
	  <%if(bolShowOffice){
		bolShowOffice = false;
		dOfficeTotal = 0d;
	  %>    
		<tr>
      <td height="26" colspan="6" class="thinborder">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+10),"OFFICE : ","","OFFICE : " + (String)vRetResult.elementAt(i+11))).toUpperCase()%></td>
    </tr>
		<%}%>
		<%
			if(i+iFieldCount+1 < vRetResult.size()){
				strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+8),"");		
				strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+9),"");	
			
				strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 8),"");		
				strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 9),"");		
				// System.out.println("strCurColl " + strCurColl);
				// System.out.println("strCurDept " + strCurDept);
				// System.out.println("strNextColl " + strNextColl);
				// System.out.println("strNextDept " + strNextDept);

				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
					bolShowOffice= true;
				}		
			}
		%>
    <tr> 
      <td height="20" align="right" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+3)%> / <%=vRetResult.elementAt(i+4)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i+6);
				dTemp = Double.parseDouble(strTemp);
				strTemp  = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i+7);
				dTemp = Double.parseDouble(strTemp);
				strTemp  = CommonUtil.formatFloat(strTemp,true);
				dTotal += dTemp;
				dOfficeTotal += dTemp;
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
    </tr>
		<%if(bolShowOffice || i+iFieldCount+1 >= vRetResult.size()){%>
    <tr> 
      <td height="20" colspan="5" align="right" class="thinborder"><strong> OFFICE TOTAL  :&nbsp; </strong></td>
      <td align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(dOfficeTotal,true)%></strong></td>
    </tr>
		<%}%>		
    <%
	//	 if(i < vRetResult.size()){
	//		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 8),"");
	//		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 9),"");
	//	 }	 	 		
		}// end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" colspan="2" align="right" class="noBorder"><strong>GRAND TOTAL  :&nbsp; </strong></td>
      <td width="12%" align="right" class="noBorder"><strong><%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td width="13%" height="20" class="noBorder">Prepared by: </td>
      <td width="75%" class="noBorder">&nbsp;<%=WI.getStrValue(WI.fillTextValue("prepared_by")).toUpperCase()%></td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="20" class="noBorder">Noted by: </td>
      <td height="20" class="noBorder">&nbsp;<%=WI.getStrValue(WI.fillTextValue("noted_by")).toUpperCase()%></td>
      <td align="right">&nbsp;</td>
    </tr>	
  </table>
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
