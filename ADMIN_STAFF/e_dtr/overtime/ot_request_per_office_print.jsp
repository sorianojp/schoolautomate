<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
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
</style>
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolShowSubTotal = false;
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Edit Overtime","ot_request_per_office.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"ot_request_per_office.jsp");	

if(bolMyHome && iAccessLevel == 0) {
	iAccessLevel = 1;	
}

if(iAccessLevel == -1){//for fatal error.
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

int iCols = 5;	
int iMaxCols = 8;
if(WI.fillTextValue("hide_stat").length() > 0)
	iMaxCols = 7;
if(WI.fillTextValue("hide_time").length() > 0)
	iMaxCols -= 1;
		

	
	int iSearchResult = 0;
	String strDateFrom = WI.fillTextValue("DateFrom");
	String strDateTo = WI.fillTextValue("DateTo");
	boolean bolPageBreak = false;
	
	ReportEDTR RE = new ReportEDTR(request);
	eDTR.OverTime ot = new eDTR.OverTime();
	boolean bolShowDeptTotal = false;
	double dGrandAmt = 0d;
	double dGrandHours = 0d;
	double dDeptAmt = 0d;
	double dDeptHours = 0d;
	double dTemp = 0d;
	
	int iCtr = 0;
	String strPrevCName = null;
	String strPrevDName = null;
	String strCurCName = null;
	String strCurDName = null;
	String strOfficeName = null;
	boolean bolNextOffice = false;
	
	String strCurEmpId = null;
	String strNxtEmpId = null;
	
	
String strSchCode = dbOP.getSchoolIndex();
if(strSchCode == null || strSchCode.length() == 0 )
	strSchCode = "";
	
	
	Vector vRetResult = null;
	vRetResult = RE.searchOvertimePerOffice(dbOP);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPage = 1;
		int iPage = 1;
		iTotalPage = vRetResult.size() / (35*iMaxRecPerPage);
		if((vRetResult.size() % (35*iMaxRecPerPage)) > 0)
			iTotalPage ++;
		
		double dSubCost = 0d;
		double dSubOTHours = 0d;
		for (;iNumRec < vRetResult.size();iPage++){
			strPrevCName = null;
			strPrevDName = null;
%>
<form  name="dtr_op">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
  	<td align="center">
		<strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br />
		<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>	
	</td>
  </tr>
</table>
<br />
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="57%" height="25" colspan="7" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME  REQUESTS FOR THE PERIOD <%=strDateFrom%> - <%=strDateTo%></strong></font></td>
  </tr>
   <tr>     
	  <td height="19" align="right" >&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>    
    </tr>
  <tr>
    <td height="18" colspan="6" align="right">Page <%=iPage%> of <%=iTotalPage%></td>
  </tr>
  <tr>
    <td height="73" colspan="6"><table width="100%" height="80" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="10%" align="center" class="thinborder">&nbsp;</td>
				<td width="22%" align="center" class="thinborder"><font size="1"><strong>Requested For</strong></font></td> 
		<td width="12%" align="center" class="thinborder"><font size="1"><strong>OT Code</strong></font></td>		       
        <td width="14%" align="center" class="thinborder"><font size="1"><strong>OT Date</strong></font></td>
		<%
		if( WI.fillTextValue("hide_time").length() == 0  ){
		%>
        <td width="16%" align="center" class="thinborder"><font size="1"><strong>Inclusive Time</strong></font></td>
		<%}%>
        <td width="8%"  align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>
		<td width="8%"  align="center" class="thinborder"><font size="1"><strong><%=(strSchCode.startsWith("EAC")? "OT AMT" : "COST")%></strong></font></td>
		<%
		if( WI.fillTextValue("hide_stat").length() == 0  ){
		%>		
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td> 
		<%}%>
						
      </tr>
      <%			
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=35,++iIncr, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				} else 
					bolPageBreak = false;	 

				if(i+35 < vRetResult.size()){
					if(i==0)
						strCurEmpId =  WI.getStrValue((String)vRetResult.elementAt(i+1),"");
					strNxtEmpId = WI.getStrValue((String)vRetResult.elementAt(i+36),"");
				}				
				if(!strCurEmpId.equals(strNxtEmpId))
					bolShowSubTotal = true;
			
			
			
				strCurCName = WI.getStrValue((String)vRetResult.elementAt(i+21));
				strCurDName = WI.getStrValue((String)vRetResult.elementAt(i+23));
				
				if(strPrevCName == null || !strPrevCName.equals(strCurCName) ||
					 strPrevDName == null || !strPrevDName.equals(strCurDName)){
			 %>
        <tr>
					<%if(strCurCName.length() == 0  || strCurDName.length() == 0){
							strTemp = " ";
						} else {
							strTemp = " - ";
						}
						strOfficeName = WI.getStrValue(strCurCName,"") + strTemp + WI.getStrValue(strCurDName,"");
					%>
          <td height="20"  colspan="<%=iMaxCols%>" class="thinborder"><strong>&nbsp;<%=strOfficeName%></strong></td>
          </tr>
        <tr>
				<%}%>
				<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
				<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+18),
									(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
				%>
        <td height="21" class="thinborder">&nbsp;<%=strTemp%></td> 
		<td height="21" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+34))%></td>        
        <%
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder">          <%=strTemp%></td>
		<%
		if( WI.fillTextValue("hide_time").length() == 0  ){
		%>
        <td align="center" nowrap class="thinborder">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - 
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
		<%}%>						 
									 
				<%
					strTemp = (String)vRetResult.elementAt(i+3);
					strTemp = CommonUtil.formatFloat(strTemp, false);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					dDeptHours += dTemp;
					dGrandHours += dTemp;
					dSubOTHours += dTemp;
				%>									 
        <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%
					strTemp = (String)vRetResult.elementAt(i+28);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					dDeptAmt += dTemp;
					dGrandAmt += dTemp;					
					dSubCost += dTemp;				
				%>
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>	
							
       <%
		if( WI.fillTextValue("hide_stat").length() == 0  ){
		
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "APPROVED";
				}else if (strTemp.equals("0")){
					strTemp = "DISAPPROVED";
				}else
					strTemp = "PENDING";
			%>
        <td class="thinborder" align="center"><font size="1">&nbsp;<%=strTemp%></font></td>	
		<%}%>			
      </tr>
		 <%
		 
		 if(i+35 < vRetResult.size())
			strCurEmpId =  strNxtEmpId;
			
		 if( bolShowSubTotal ||  i+35 >= vRetResult.size() ){%>
		<tr>	
		<%
		iCols = 5;	
		if( WI.fillTextValue("hide_time").length() != 0  ){
			iCols = 4;		
		}
		%>					
        <td height="21" class="thinborder" colspan="<%=iCols%>" align="right"><strong>Employee Total</strong> &nbsp;</td>
        <td class="thinborder" align="right">&nbsp;<%=CommonUtil.formatFloat(dSubOTHours,false)%>&nbsp;</td>		
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dSubCost,true)%>&nbsp;</td>	
		
		<%
		if( WI.fillTextValue("hide_stat").length() == 0  ){
		%>		
			<td class="thinborder"><font size="1">&nbsp;</font></td>				
		<%}%>
		
      </tr>
		
		
		<%
			dSubCost = 0d;
			dSubOTHours = 0d;
			bolShowSubTotal = false;
		}//end of show subtotal	
		 
		 
		 
		 
		 
		 	if(i+36 < vRetResult.size()){				
				if(!(strCurCName).equals(WI.getStrValue((String)vRetResult.elementAt(i + 56),"")) 
				|| !(strCurDName).equals(WI.getStrValue((String)vRetResult.elementAt(i + 58),""))){
					bolShowDeptTotal = true;
				}else{
					bolShowDeptTotal = false;
				}
			}%>
			<%
			if(!bolShowDeptTotal && iNumRec + 35 >= vRetResult.size())
				bolShowDeptTotal = true;
			%>	
			
			<%if(bolShowDeptTotal){%>
			<tr>
				<%
				if( WI.fillTextValue("hide_time").length() != 0  )
					iCols = 4;
				%>
				<td height="21" colspan="<%=iCols%>" align="right" class="thinborder"><strong>Total For <%=strOfficeName%>&nbsp;</strong></td>
				<td height="21" align="right" class="thinborder"><%=CommonUtil.formatFloat(dDeptHours, false)%>&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dDeptAmt, true)%>&nbsp;</td>
				<%if( WI.fillTextValue("hide_stat").length() == 0  ){%>
			  <td align="right" class="thinborderBOTTOM">&nbsp;</td>
			  	<%}%>
			</tr>
			<%
				dDeptHours = 0d;
				dDeptAmt = 0d;
			}%>
			
      <%
				strPrevCName = WI.getStrValue(strCurCName);
				strPrevDName = WI.getStrValue(strCurDName);
			}%>

			<%if(iNumRec >= vRetResult.size()){%>
			<tr>
				<%
				if( WI.fillTextValue("hide_time").length() != 0  )
					iCols = 4;
				%>
				<td height="21" colspan="<%=iCols%>" align="right" class="thinborder"><strong>Grand Total&nbsp; </strong></td>
				<td height="21" align="right" class="thinborder"><%=CommonUtil.formatFloat(dGrandHours, false)%>&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dGrandAmt, true)%>&nbsp;</td>
				<%if( WI.fillTextValue("hide_stat").length() == 0  ){%>
				  <td align="right" class="thinborderBOTTOM">&nbsp;</td>
				<%}%> 
			</tr>
			<%}%>
    </table>		</td>
  </tr>
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