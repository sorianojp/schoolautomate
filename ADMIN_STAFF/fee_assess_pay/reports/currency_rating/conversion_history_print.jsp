<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborderALL {
    border-top: solid 1px #FFFFFF;
    border-left: solid 1px #FFFFFF;
    border-right: solid 1px #FFFFFF;
    border-bottom: solid 1px #FFFFFF;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>

<title>Welcome iHRIMS</title>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../css/frontPageLayout.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="javascripts/Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script></head>
<%@ page language="java" import="utility.*,java.util.Vector, locker.Currency " %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo  = null; 

	String strErrMsg  		 = null;
	String strTemp    		 = null;
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
		
	Currency currency = new Currency();	
	try{
		dbOP = new DBOperation();
	}catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	 

	int iSearchResult = 0;
	int i = 0; 
	boolean bolPageBreak = false;
	vRetResult = currency.operateOnConvertionHistory(request,dbOP, 4); 
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
	//System.out.println("vRetResult after display: " + vRetResult );
		
%>
<body onload="javascrip:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
    <tr> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>CURRENCY CONVERSION HISTORY </strong></td>
    </tr>	
	<tr align="center">
		<td width="12%" height="21" class="thinborder"><strong>Date </strong></td>
		<td width="22%" class="thinborder"><strong>Currency</strong></td>
		<td width="15%" class="thinborder"><strong>Amount</strong></td>
		<td width="33%" class="thinborder"><strong>Created by</strong></td>
		</tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>
		<tr>			
			<td height="22" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%>&nbsp;</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>					
	<%}%> <!-- end of for loop and if -->
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
if(dbOP!=null)
	dbOP.cleanUP();
%>

