<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:1in;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }
  
  body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 14px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;	
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;	
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
    }


</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#FFFFFFF">
<form name="form_" action="inv_view_inventory_print.jsp" method="post" >
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_view_inventory_print.jsp");
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

	Vector vRetResult = null;
	int iTemp = 0;
	

	double dPageTotal  = 0d;
	double dGrandTotal = 0d;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	int iElemCount = 0;
	InventorySearch InvSearch = new InventorySearch();
	vRetResult = InvSearch.viewInventorybyOffice(dbOP,request);
	if(vRetResult != null && vRetResult.size() > 0)
		iElemCount = InvSearch.getElemCount();
	boolean bolPageBreak  = false;
	boolean bolLooped = false;
	double dTotal = 0d;
	if (vRetResult != null) {
	int i = 0; 
	int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"10"));
	String strCurCollege = null;
	String strCurDept = null;
	String strCollName = null;
	String strDeptName = null;
	String strTemp2 = null;
	String[] astrLifeSpanUnit = {"Day(s)","Month(s)", "Year(s)"};
	String[] astrSemester = {"Summer","1st Semester", "2nd Semester", "3rd Semester", "4th Semester"};
	int iNumRec = 0; //System.out.println(vRetResult);
	int iIncr    = 1;
	for (;iNumRec < vRetResult.size();){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#000000"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF"><div align="center"><div align="center"><font size="2"><strong>VMA Global College and VMA Training Center</strong><br>
	  (Formerly Visayan Maritime Academy)<br>
	  (Asian Mari- tech Development Corporation)<br>
	  Sum-ag, Bacolod City</font></div></div></td>
    </tr>
</table>	
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
        <td height="25" colspan="10" align="center">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="10" align="center"><strong>PROPERTY CUSTODIAN</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td height="25" colspan="10" align="center">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td height="25" colspan="10" align="center"><strong>INVENTORY LIST OF TOOLS /INSTRUMENTS/EQUIPMENT</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td height="25" colspan="10" align="center">
		<%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]+", S.Y. "+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>		</td>
    </tr>
		<%if(WI.fillTextValue("status_name").length() > 0){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="10"><%=WI.fillTextValue("status_name")%></td>
    </tr>
		<%}%>
		<%
			if(iNumRec == 0){
				strCollName = (String)vRetResult.elementAt(12);
				strDeptName = (String)vRetResult.elementAt(13);
			}
		%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="10">OFFICE : <%=WI.getStrValue(strCollName,strDeptName)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">	
    
	<tr>
      <td width="19%" height="18" align="center" class="thinborder"><font size="1"><strong>NAME OF TOOLS, INSTRUMENTS AND EQUIPMENTS</strong></font></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>SPECIFICATIONS</strong></font></td>
      
      <td width="9%" align="center" class="thinborder"><strong><font size="1">PROPERTY ID<br>NUMBER</font></strong></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">ESTIMATED LIFE</font></strong></td>
	
	  <td width="9%" align="center" class="thinborder"><strong><font size="1">PREVIOUS # OF UNITS/QTY </font></strong></td>
	  <td width="9%" align="center" class="thinborder"><strong><font size="1">ADDT'L PURCHASES MR #/QTY</font></strong></td>			
      <td width="9%" align="center" class="thinborder"><strong><font size="1">CURRENT TOTAL QTY.</font></strong></td>
	 
      <td colspan="2" align="center" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
	  
	 
    </tr>   
	
	
	 
     <% bolLooped = false;		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=iElemCount,++iIncr, ++iCount){
		i = iNumRec;		
		
		if (iCount > iMaxRecPerPage){
			strCollName = (String) vRetResult.elementAt(i+11);
			strDeptName = (String) vRetResult.elementAt(i+12);
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
			
			if(bolLooped){
				if(!strCurCollege.equals((String) vRetResult.elementAt(i)) ||
					 !strCurDept.equals((String) vRetResult.elementAt(i+1))){
					strCollName = (String) vRetResult.elementAt(i+11);
					strDeptName = (String) vRetResult.elementAt(i+12);
					bolPageBreak = true;
					break;
				}
			}
	  %>
    
	
	
	 <tr>
        <td height="18" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
        <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
        <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+19));
		if(strTemp.length() > 0)
			strTemp += " " +astrLifeSpanUnit[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+22)))];
		%>
        <td class="thinborder" align="center"><%=strTemp%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+20),"0");
		//if(strTemp.equals("0"))
		//	strTemp = WI.getStrValue(vRetResult.elementAt(i+4),"0");
		
		%>
        <td class="thinborder" align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		dTotal = 0d;
		try{
			dTotal = Double.parseDouble(WI.getStrValue(strTemp,"0")) + Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i+21),"0"));
		}catch(Exception e){}
		%>
        <td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+21),"&nbsp;")%></td>
		<%
		if(dTotal == 0)
			strTemp = "&nbsp;";
		else
			strTemp = Double.toString(dTotal);
		%>
        <td class="thinborder" align="center"><%=strTemp%></td>
        <td width="9%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+17),"&nbsp;")%></td>
        <td width="9%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+23),"&nbsp;")%></td>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i);
			strCurDept = (String) vRetResult.elementAt(i+1);
		} // end for loop%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="19"  colspan="3">
		<%if(strSchCode.startsWith("WUP")){%>
	  		<strong>Page Total: <%=CommonUtil.formatFloat(dPageTotal, true)%></strong>
	  	<%dPageTotal = 0d;}else{%>
	  		&nbsp;
	  	<%}%>
	  </td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>


<table cellpadding="0" cellspacing="0" border="0" Width="100%">
	<tr>
		<td width="12%" height="25">CONDUCTED BY:</td>
		<td width="25%" height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
		<td width="5%" height="25">DATE:</td>
		<td width="12%" height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
		<td width="11%" height="25">  CONFORME:</td>
		<td width="18%" height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
		<td width="5%" height="25">DATE:</td>
		<td width="12%" height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
	</tr>
	<tr>
	    <td height="25">PREPARED BY:</td>
	    <td height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
	    <td height="25">DATE:</td>
	    <td height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
	    <td height="25">VERIFIED:</td>
	    <td height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
	    <td height="25">DATE:</td>
	    <td height="25" valign="bottom"><div style="width:90%; border-bottom:solid 1px #000000;"></div></td>
	    </tr>
</table>


<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID.</td>
		<td>: Property 0024</td>
	</tr>
	<tr>
		<td>Rev. Number</td>
		<td>: 01</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 09.01.06</td>
	</tr>
</table>
</div>
  <input type="hidden" name="print_pg">
</form>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>