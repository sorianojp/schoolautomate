<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
td{
	font-size:11px;
}
a{
	text-decoration:none;
}
.style3 {font-size: 9px}

    TABLE.thinborder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


</style>

</head>


<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.FAFeeAdjustmentCPU,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","add_drop_entry.jsp");
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



String[] astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}


//end of authenticaion code.

float fTotalTutionFee = 0f;
float fTuitionA = 0;
float fDiscount = 0;
float fTutionFee = 0;
float fMiscFee = 0;
boolean bolIsTempStud = false;

int iCtr = 1;

//float fTotalAdjustment = 0f;


	String strDiscount = null;
	String strJVIndex = WI.fillTextValue("jv_index");
	String strTotalAmount = null;
	String strAddDropStat = WI.fillTextValue("add_drop_stat");

	FAFeeAdjustmentCPU fAdjust = new FAFeeAdjustmentCPU();
	enrollment.FAFeeReportsCPU fReports = new enrollment.FAFeeReportsCPU();

	Vector vRetResult =  fAdjust.operateOnTempAddDrop(dbOP,request,6,strJVIndex);
	
	if (vRetResult == null){
		strErrMsg = fAdjust.getErrMsg();
	}
	
	Vector vRetSummary = fReports.viewAddDropSummaryPerCollegePerYear(dbOP,request);

	String[] astrSemester = {"Summer", "First Semester", "Second Semester", "Third Semester"};

	int iSemester = Integer.parseInt(WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"),"1")); 

if (strErrMsg != null) { 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
 
<% }else{

	if (vRetResult != null && vRetResult.size() > 0 && strAddDropStat.equals("0")) { 

	for (int i = 0; i< vRetResult.size();) {

%>   

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  	 <td> C P U  - <%=astrSemester[iSemester]%> - Report on Adding / Dropping Charges </td>
  </tr>
  <tr>
    <td height="30">&nbsp;</td>
  </tr>
 </table>

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="3%" class="thinborder"><font size="1">No.</font></td>
      <td width="9%" class="thinborder"><font size="1">&nbsp;ID Number </font></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"> &nbsp;Name</font></div></td>
      <td width="9%" class="thinborder"><font size="1">COURSE &amp; YR</font></td>
      <td width="7%" height="12" class="thinborder"><div align="right"><font size="1">TuitAdd</font></div></td>
      <td width="7%" class="thinborder"><div align="right"><font size="1">TuitDrop&nbsp;</font></div></td>
<!--
      <td width="7%" height="12" class="thinborder"><div align="right"><font size="1">ADD&nbsp;</font></div></td>
      <td width="7%" class="thinborder"><div align="right"><font size="1">DROP&nbsp;</font></div></td>
-->
      <td width="7%" height="12" class="thinborder"><div align="right"><font size="1">LabAdd</font></div></td>
      <td width="7%" class="thinborder"><div align="right"><font size="1">LabDrop</font></div></td>
      <td width="7%" height="12" class="thinborder"><div align="right"><font size="1">AddD</font></div></td>
      <td width="7%" class="thinborder"><div align="right"><font size="1">DROP&nbsp;</font></div></td>
    </tr>
	
<% 	
	for(; i < vRetResult.size(); i+=20, ++iCtr){
%>
    <tr>
      <td class="thinborder"><font size="1">&nbsp;<%=iCtr%></font></td>
      <td height="20" class="thinborder">
	    <font size="1"><%=(String)vRetResult.elementAt(i+19)%></font>
	    <font size="1">
	    <input type="hidden" name="fee_hist_adj_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
      </font></td>
      <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td height="20" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3) + 
	  		WI.getStrValue((String)vRetResult.elementAt(i+4), "(",")","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+5), " ","","")%></font></td>

      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
<!--
      <td height="20" class="thinborder"><div align="right"><font size="1"><%//=(String)vRetResult.elementAt(i+15)%></font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1"><%//=(String)vRetResult.elementAt(i+16)%></font></div></td>
-->
      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+14)%></font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+11)%></font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></div></td>
    </tr>
<%
	if (iCtr != 0 && iCtr%3 == 0)
		break; 
	} // end for loop
%>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%  i+=20; ++iCtr;
  } 
}

	if (vRetResult != null && vRetResult.size() > 0 &&  strAddDropStat.equals("1")) { 

	for (int i = 0; i< vRetResult.size();) {
%>   
  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  	 <td> C P U  - <%=astrSemester[iSemester]%> - Report on Adding / Dropping Charges </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
 </table>


  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="4%" class="thinborder"><font size="1">&nbsp;No.</font></td>
      <td width="14%" height="25" class="thinborder"><font size="1">ID Number </font></td>
      <td width="33%" class="thinborder"><div align="center"><font size="1">&nbsp;STUDENT NAME</font></div></td>
      <td width="12%" class="thinborder"><font size="1">COURSE &amp; YR</font></td>
      <td width="8%" height="12" class="thinborder"><div align="right"><font size="1">TuitAdd&nbsp;</font></div></td>
      <td width="8%" height="12" class="thinborder"><div align="right"><font size="1">MiscAdd&nbsp;</font></div></td>
      <td width="10%" height="12" class="thinborder"><div align="right"><font size="1">OthCharAdd&nbsp;</font></div></td>
      <td width="11%" height="12" class="thinborder"><div align="right"><font size="1">DiscAdd&nbsp;</font></div></td>
    </tr>
	
<% 	
	for(; i < vRetResult.size(); i+=20, ++iCtr){
	
	
%>
    <tr>
      <td class="thinborder">&nbsp;<%=iCtr%></td>
      <td height="20" class="thinborder">
	  <font size="1"><%=(String)vRetResult.elementAt(i+19)%></font>
	  <input type="hidden" name="fee_hist_adj_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">      </td>
      <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td height="20" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3) + 
	  		WI.getStrValue((String)vRetResult.elementAt(i+4), "(",")","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+5), " ","","")%></font></td>

      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+9)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+15)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+13)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+11)%></div></td>
    </tr>
<%
	if (iCtr != 0 && iCtr%3 == 0)
		break; 
	} // end for loop
%>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>

<%  i+=20; ++iCtr;
  } 
}

	if (vRetResult != null && vRetResult.size() > 0 && strAddDropStat.equals("2")) { 
	for( int i = 0; i < vRetResult.size();){
%>   
  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  	 <td> C P U  - <%=astrSemester[iSemester]%> - Report on Adding / Dropping Charges </td>
  </tr>
  <tr>
    <td height="30">&nbsp;</td>
  </tr>
 </table>


  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="4%" height="19" class="thinborder"><font size="1">&nbsp;No.</font></td>
      <td width="14%" class="thinborder"><font size="1">ID Number </font></td>
      <td width="33%" class="thinborder"><div align="center"><font size="1">&nbsp;STUDENT NAME</font></div></td>
      <td width="12%" class="thinborder"><font size="1">COURSE &amp; YR</font></td>
      <td width="8%" height="19" class="thinborder"><div align="right"><font size="1">TuitDrp&nbsp;</font></div></td>
      <td width="8%" class="thinborder"><div align="right"><font size="1">MiscDrp&nbsp;</font></div></td>
      <td width="9%" class="thinborder"><div align="right"><font size="1">OthCharDrp&nbsp;</font></div></td>
      <td width="12%" class="thinborder"><div align="right"><font size="1">DiscDrp&nbsp;</font></div></td>
    </tr>
	
<% 	for( ; i < vRetResult.size(); i+=20, ++iCtr){ %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCtr%></td>
      <td height="20" class="thinborder">  <font size="1"><%=(String)vRetResult.elementAt(i+19)%></font>  </td>
      <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td height="20" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3) + 
	  		WI.getStrValue((String)vRetResult.elementAt(i+4), "(",")","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+5), " ","","")%></font></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+10)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+16)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+14)%></div></td>
      <td height="20" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+12)%></div></td>
	</tr>
<%
	if (iCtr != 0 && iCtr%3 == 0)
		break; 
	} // end for loop
%>
</table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<% i+=20; ++iCtr;
  } 
}
	if (vRetSummary != null && vRetSummary.size() > 0) { 
%>   

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  	 <td> C P U  - <%=astrSemester[iSemester]%> - Report on Adding / Dropping Charges </td>
  </tr>
  <tr>
    <td height="30">&nbsp;</td>
  </tr>
 </table>

<div align="center"><strong>S U M M A R Y </strong><br></div>

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="30%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">First Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Second Year&nbsp; </font></div></td>
      <td width="10%" height="13" class="thinborder"><div align="right"><font size="1">Third Year &nbsp;</font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Fourth Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Fifth Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Sixth Year&nbsp;</font> </div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Total&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
	
<% 	
	String strCurrStatus = null;
	Vector vSummary = (Vector)vRetSummary.elementAt(0);
	double dRowTotal = 0d;
	boolean bolInfiniteLoop = false;
	for(int i = 1; i < vRetSummary.size(); ){ 
	bolInfiniteLoop = true;
		strCurrStatus = (String)vRetSummary.elementAt(i+1);
		dRowTotal = 0d;
		
	if((String)vRetSummary.elementAt(i) != null) {
	// show college
	
		if (i!= 1) {
%>
    <tr>
      <td height="20" colspan="8" class="thinborder">&nbsp;</td>
    </tr>
		<% } %>
    <tr>
      <td height="20" colspan="8" class="thinborder"><u><%=(String)vRetSummary.elementAt(i)%></u></td>
    </tr>
<%
	vRetSummary.setElementAt(null,i);
}%> 
    <tr>
      <td height="20" class="thinborder">  <font size="1">
	  <% if ( i < vRetSummary.size()) {%>
		  <%=(String)vRetSummary.elementAt(i+1)%>
	  <%}%> 
	  </font></td>	
	
      <td height="20" align="right" class="thinborder">  <font size="1">
	  <% 
	  if ( i < vRetSummary.size() && 
	  	  	   vRetSummary.elementAt(i) == null &&
			  ((String)vRetSummary.elementAt(i+2)).equals("1") && 
			  strCurrStatus.equals((String)vRetSummary.elementAt(i+1))) {%>
	  <%=(String)vRetSummary.elementAt(i+3)%>
	  <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
	  	bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
	  </font></td>
      <td height="20" class="thinborder"><div align="right"><font size="1">
        <% if ( i < vRetSummary.size() && 
  	  	       vRetSummary.elementAt(i) == null &&
				strCurrStatus.equals((String)vRetSummary.elementAt(i+1)) && 
			  ((String)vRetSummary.elementAt(i+2)).equals("2")) {%>
        <%=(String)vRetSummary.elementAt(i+3)%>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%>  
      </font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1">
	  	  <% if ( i < vRetSummary.size() && 
  	  	    vRetSummary.elementAt(i) == null &&
  			strCurrStatus.equals((String)vRetSummary.elementAt(i+1)) && 
		  ((String)vRetSummary.elementAt(i+2)).equals("3")) {%>
        <%=(String)vRetSummary.elementAt(i+3)%>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
      </font></div></td>
      <td height="20" class="thinborder">	  	  
	  	  <div align="right">
	  	    <% if ( i < vRetSummary.size() && 
		  	  vRetSummary.elementAt(i) == null && 
				strCurrStatus.equals((String)vRetSummary.elementAt(i+1)) && 
			  ((String)vRetSummary.elementAt(i+2)).equals("4")) {%>
	        <%=(String)vRetSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%>  
	  </div></td>
      <td height="20" class="thinborder">
 	    <div align="right">
 	      <% if ( i < vRetSummary.size() && 
		  	  vRetSummary.elementAt(i) == null &&
  			  strCurrStatus.equals((String)vRetSummary.elementAt(i+1)) && 
			  ((String)vRetSummary.elementAt(i+2)).equals("5")) {%>
	      <%=(String)vRetSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
      </div></td>
      <td height="20" class="thinborder">
 	    <div align="right">
 	      <% if ( i < vRetSummary.size() && 
				strCurrStatus.equals((String)vRetSummary.elementAt(i+1)) && 
			  ((String)vRetSummary.elementAt(i+2)).equals("6")) {%>
	      <%=(String)vRetSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vRetSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 	    
		</div>		</td>
      <td height="20" class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dRowTotal,true)%></div></td>
   </tr>
<%
		if (bolInfiniteLoop){
			System.out.println("infinite loop:add_drop_entry.jsp");
			System.out.println(vRetSummary);
			System.out.println(i);
			System.out.println((String)vRetSummary.elementAt(i));
			System.out.println((String)vRetSummary.elementAt(i+1));
			System.out.println((String)vRetSummary.elementAt(i+2));
			System.out.println((String)vRetSummary.elementAt(i+3));
			break;
		}
	} // end for loop
%>
</table>

<DIV style="page-break-before:always" >&nbsp;</DIV>

<% if (vSummary != null && vSummary.size() > 0) {%> 


  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  	 <td> C P U  - <%=astrSemester[iSemester]%> - Report on Adding / Dropping Charges </td>
  </tr>
  <tr>
    <td height="30">&nbsp;</td>
  </tr>
 </table>

<div align="center"><strong>S U M M A R Y </strong><br></div>

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="30%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">First Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Second Year&nbsp; </font></div></td>
      <td width="10%" height="25" class="thinborder"><div align="right"><font size="1">Third Year &nbsp;</font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Fourth Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Fifth Year&nbsp; </font></div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Sixth Year&nbsp;</font> </div></td>
      <td width="10%" class="thinborder"><div align="right"><font size="1">Total&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
	
<% 	
	for(int i = 0; i < vSummary.size(); ){ 
	bolInfiniteLoop = true;
		strCurrStatus = (String)vSummary.elementAt(i+1);
		dRowTotal = 0d;
		
%> 
    <tr>
      <td height="20" class="thinborder">  <font size="1">
	  <% if ( i < vSummary.size()) {%>
		  <%=(String)vSummary.elementAt(i+1)%>
	  <%}%> 
	  </font></td>	
	
      <td height="20" align="right" class="thinborder">  <font size="1">
	  <% 
	  if ( i < vSummary.size() && 
	  	  	   vSummary.elementAt(i) == null &&
			  ((String)vSummary.elementAt(i+2)).equals("1") && 
			  strCurrStatus.equals((String)vSummary.elementAt(i+1))) {%>
	  <%=(String)vSummary.elementAt(i+3)%>
	  <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
	  	bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
	  </font></td>
      <td height="20" class="thinborder"><div align="right"><font size="1">
        <% if ( i < vSummary.size() && 
  	  	       vSummary.elementAt(i) == null &&
				strCurrStatus.equals((String)vSummary.elementAt(i+1)) && 
			  ((String)vSummary.elementAt(i+2)).equals("2")) {%>
        <%=(String)vSummary.elementAt(i+3)%>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%>  
      </font></div></td>
      <td height="20" class="thinborder"><div align="right"><font size="1">
	  	  <% if ( i < vSummary.size() && 
  	  	    vSummary.elementAt(i) == null &&
  			strCurrStatus.equals((String)vSummary.elementAt(i+1)) && 
		  ((String)vSummary.elementAt(i+2)).equals("3")) {%>
        <%=(String)vSummary.elementAt(i+3)%>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
        </font></div></td>
      <td height="20" class="thinborder">	  	  
	  	  <div align="right">
	  	    <% if ( i < vSummary.size() && 
		  	  vSummary.elementAt(i) == null && 
				strCurrStatus.equals((String)vSummary.elementAt(i+1)) && 
			  ((String)vSummary.elementAt(i+2)).equals("4")) {%>
	        <%=(String)vSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%>  
		</div></td>
      <td height="20" class="thinborder">
 	    <div align="right">
 	      <% if ( i < vSummary.size() && 
		  	  vSummary.elementAt(i) == null &&
  			  strCurrStatus.equals((String)vSummary.elementAt(i+1)) && 
			  ((String)vSummary.elementAt(i+2)).equals("5")) {%>
	      <%=(String)vSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 
	    </div></td>
      <td height="20" class="thinborder">
 	    <div align="right">
 	      <% if ( i < vSummary.size() && 
				strCurrStatus.equals((String)vSummary.elementAt(i+1)) && 
			  ((String)vSummary.elementAt(i+2)).equals("6")) {%>
	      <%=(String)vSummary.elementAt(i+3)%></font>
        <% dRowTotal += Double.parseDouble(ConversionTable.replaceString((String)vSummary.elementAt(i+3),",",""));
		bolInfiniteLoop = false;
	  	i+=4; }else{%> 0.00 <%}%> 	    
		</div>	  </td>
      <td height="20" class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dRowTotal,true)%></div></td>
   </tr>
<%
		if (bolInfiniteLoop){
			System.out.println("infinite loop:add_drop_entry.jsp");
			System.out.println(vSummary);
			System.out.println(i);
			System.out.println((String)vSummary.elementAt(i));
			System.out.println((String)vSummary.elementAt(i+1));
			System.out.println((String)vSummary.elementAt(i+2));
			System.out.println((String)vSummary.elementAt(i+3));
			break;
		}
	} // end for loop
%>
</table>
<% 	} 
   }  
  }  %> 
  
</body>
</html>
<%
dbOP.cleanUP();
%>
